
GAME_DIR=game
BIN_DIR=bin
LIBS_DIR=$(GAME_DIR)/libs
GAME=$(BIN_DIR)/backdoor.love

LOVE_WIN32=$(BIN_DIR)/love-11.1-win32.zip
BIN_DIR_WIN32=$(BIN_DIR)/win32
GAME_WIN32=$(BIN_DIR_WIN32)/backdoor.exe

LUX_LIB=$(LIBS_DIR)/lux
LUX_REPO=externals/luxproject

STEAMING_LIB=$(LIBS_DIR)/steaming
STEAMING_REPO=externals/STEAMING
STEAMING_MODULES=$(STEAMING_REPO)/clean_template/font.lua \
								 $(STEAMING_REPO)/clean_template/res_manager.lua \
								 $(STEAMING_REPO)/clean_template/util.lua \
								 $(STEAMING_REPO)/clean_template/classes \
								 $(STEAMING_REPO)/clean_template/extra_libs

INPUT_LIB=$(LIBS_DIR)/input
INPUT_REPO=externals/input

IMGUI_LIB=imgui.so
IMGUI_DLL=imgui.dll
LUAJIT_DLL=lua51.dll
IMGUI_REPO=externals/love-imgui
IMGUI_BUILD_DIR=externals/love-imgui/build

CPML_LIB=$(LIBS_DIR)/cpml
CPML_REPO=externals/cpml

DKJSON_LIB=$(LIBS_DIR)/dkjson.lua

DEPENDENCIES=$(LUX_LIB) $(STEAMING_LIB) $(IMGUI_LIB) $(CPML_LIB) $(DKJSON_LIB) $(INPUT_LIB)

## MAIN TARGETS

all: $(DEPENDENCIES)
	love game $(FLAGS)

update:
	cd $(LUX_REPO); git pull
	cd $(STEAMING_REPO); git pull
	cd $(INPUT_REPO); git pull

$(BIN_DIR):
	mkdir $(BIN_DIR)

.PHONY: export
export: $(GAME)

.PHONY: windows
windows: $(BIN_DIR_WIN32)/backdoor.exe

.PHONY: deploy
deploy: $(GAME) $(GAME_WIN32)
	cd $(BIN_DIR_WIN32); zip -r backdoor-win32.zip *; mv backdoor-win32.zip ..
	scp $(GAME) $(BIN_DIR)/backdoor-win32.zip kazuo@uspgamedev.org:/var/docker-www/static/downloads/projects/backdoor/nightly/

$(GAME): $(DEPENDENCIES) $(BIN_DIR)
	cd game; zip -r backdoor.love *
	mv game/backdoor.love $(GAME)

## LUX

$(LUX_LIB): $(LUX_REPO)
	cp -r $(LUX_REPO)/lib/lux $(LUX_LIB)

$(LUX_REPO):
	git clone https://github.com/Kazuo256/luxproject.git $(LUX_REPO)

## STEAMING

$(STEAMING_LIB): $(STEAMING_REPO)
	mkdir $(STEAMING_LIB)
	cp -r $(STEAMING_MODULES) $(STEAMING_LIB)

$(STEAMING_REPO):
	git clone https://github.com/uspgamedev/STEAMING.git $(STEAMING_REPO)

## INPUT

$(INPUT_LIB): $(INPUT_REPO)
	cp -r $(INPUT_REPO) $(INPUT_LIB)

$(INPUT_REPO):
	git clone https://github.com/orenjiakira/input.git $(INPUT_REPO)

## IMGUI

$(IMGUI_DLL):
	wget -O $(IMGUI_DLL) https://uspgamedev.org/downloads/libs/windows/x86/imgui.dll

$(IMGUI_LIB): $(IMGUI_BUILD_DIR)
	cd $(IMGUI_BUILD_DIR); cmake .. && $(MAKE)
	cp $(IMGUI_BUILD_DIR)/imgui.so $(IMGUI_LIB)

$(IMGUI_BUILD_DIR): $(IMGUI_REPO)
	mkdir $(IMGUI_BUILD_DIR)

$(IMGUI_REPO):
	git clone https://github.com/slages/love-imgui.git $(IMGUI_REPO)

## CPML

$(CPML_LIB): $(CPML_REPO)
	mkdir $(CPML_LIB)
	cp -r $(CPML_REPO)/modules $(CPML_LIB)
	cp -r $(CPML_REPO)/init.lua $(CPML_LIB)

$(CPML_REPO):
	git clone https://github.com/excessive/cpml.git $(CPML_REPO)

## DKJSON

$(DKJSON_LIB):
	wget -O $(DKJSON_LIB) -- http://dkolf.de/src/dkjson-lua.fsl/raw/dkjson.lua?name=16cbc26080996d9da827df42cb0844a25518eeb3

## Windows

$(BIN_DIR_WIN32): $(BIN_DIR)
	mkdir -p $(BIN_DIR_WIN32)

$(GAME_WIN32): $(BIN_DIR) $(IMGUI_DLL) $(LUAJIT_DLL) $(LOVE_WIN32) $(GAME)
	rm -rf $(BIN_DIR_WIN32)
	unzip $(LOVE_WIN32) -d $(BIN_DIR)
	mv $(BIN_DIR)/love-11.1.0-win32 $(BIN_DIR_WIN32)
	cp $(IMGUI_DLL) $(LUAJIT_DLL) $(BIN_DIR_WIN32)
	cat $(BIN_DIR_WIN32)/love.exe $(GAME) > $(GAME_WIN32)
	rm $(BIN_DIR_WIN32)/love.exe $(BIN_DIR_WIN32)/lovec.exe

$(LOVE_WIN32): $(BIN_DIR)
	wget -O $(LOVE_WIN32) https://bitbucket.org/rude/love/downloads/love-11.1-win32.zip

$(LUAJIT_DLL):
	wget -O $(LUAJIT_DLL) https://uspgamedev.org/downloads/libs/windows/x86/lua51.dll

## Deploy


## CLEAN UP

.PHONY: clean
clean:
	rm -rf $(DEPENDENCIES)

.PHONY: purge
purge: clean
	rm -rf externals/*

