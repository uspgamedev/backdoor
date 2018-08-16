
GAME_DIR=game
BIN_DIR=bin
LIBS_DIR=$(GAME_DIR)/libs
GAME=$(BIN_DIR)/backdoor.love

DEPLOY_SITE=https://uspgamedev.org
DEPLOY_PATH=downloads/projects/backdoor
DEPLOY_URL=$(DEPLOY_SITE)/$(DEPLOY_PATH)

BIN_DIR_WIN32=$(BIN_DIR)/win32
BIN_DIR_WIN32_PACKAGE=$(BIN_DIR_WIN32)/backdoor
BIN_DIR_WIN32_DEPS=$(BIN_DIR_WIN32)/deps
LOVE_WIN32=$(BIN_DIR_WIN32_DEPS)/love-11.1-win32.zip
GAME_WIN32=$(BIN_DIR_WIN32)/backdoor-win32.zip

BIN_DIR_LINUX64=$(BIN_DIR)/linux64
GAME_LINUX64=$(BIN_DIR_LINUX64)/backdoor-x86_64.AppImage
BIN_DIR_LINUX64_IMG=$(BIN_DIR_LINUX64)/image
GAME_LINUX64_TEMPLATE_NAME=backdoor-appimage-x86_64-template.tgz
GAME_LINUX64_TEMPLATE_URL=$(DEPLOY_URL)/$(GAME_LINUX64_TEMPLATE_NAME)
GAME_LINUX64_TEMPLATE=$(BIN_DIR_LINUX64_IMG)/$(GAME_LINUX64_TEMPLATE_NAME)
APPIMG_TOOL_NAME=appimage-x86_64.AppImage
APPIMG_TOOL=$(BIN_DIR_LINUX64_IMG)/$(APPIMG_TOOL_NAME)
APPIMG_TOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage

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
IMGUI_DLL=$(BIN_DIR_WIN32_DEPS)/imgui.dll
LUAJIT_DLL=$(BIN_DIR_WIN32_DEPS)/lua51.dll
IMGUI_REPO=externals/love-imgui
IMGUI_BUILD_DIR=externals/love-imgui/build
IMGUI_BUILD_MAKEFILE=$(IMGUI_BUILD_DIR)/Makefile
IMGUI_BINARY=$(IMGUI_BUILD_DIR)/imgui.so

CPML_LIB=$(LIBS_DIR)/cpml
CPML_REPO=externals/cpml

DKJSON_LIB=$(LIBS_DIR)/dkjson.lua

DEPENDENCIES=$(LUX_LIB) $(STEAMING_LIB) $(IMGUI_LIB) $(CPML_LIB) $(DKJSON_LIB) $(INPUT_LIB)

BUILD_TYPE=nightly

## MAIN TARGETS

all: $(DEPENDENCIES)
	love game $(FLAGS)

update:
	cd $(LUX_REPO); git pull
	cd $(STEAMING_REPO); git pull
	cd $(INPUT_REPO); git pull

.PHONY: export
export: $(GAME)

.PHONY: windows
windows: $(BIN_DIR_WIN32)/backdoor.exe

.PHONY: deploy
deploy: $(GAME) $(GAME_WIN32) $(GAME_LINUX64)
	scp $(GAME) $(GAME_WIN32) $(GAME_LINUX64) kazuo@uspgamedev.org:/var/docker-www/static/downloads/projects/backdoor/$(BUILD_TYPE)/

$(GAME): $(DEPENDENCIES)
	mkdir -p $(BIN_DIR)
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

$(IMGUI_LIB): $(IMGUI_BINARY)
	cp -f $(IMGUI_BUILD_DIR)/imgui.so $(IMGUI_LIB)

$(IMGUI_BINARY): $(IMGUI_BUILD_MAKEFILE)
	$(MAKE) -C $(IMGUI_BUILD_DIR)

$(IMGUI_BUILD_MAKEFILE): $(IMGUI_BUILD_DIR)
	cd $(IMGUI_BUILD_DIR) && cmake ..

$(IMGUI_BUILD_DIR): $(IMGUI_REPO)
	mkdir -p $(IMGUI_BUILD_DIR)

$(IMGUI_REPO):
	git clone https://github.com/kazuo256/love-imgui.git $(IMGUI_REPO)

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

## Linux build

$(GAME_LINUX64_TEMPLATE): $(GAME)
	mkdir -p $(BIN_DIR_LINUX64_IMG)
	wget -O $(GAME_LINUX64_TEMPLATE) -- $(GAME_LINUX64_TEMPLATE_URL)

$(APPIMG_TOOL): $(GAME)
	mkdir -p $(BIN_DIR_LINUX64_IMG)
	wget -O $(APPIMG_TOOL) -- $(APPIMG_TOOL_URL)
	chmod +x $(APPIMG_TOOL)

$(GAME_LINUX64): $(GAME) $(GAME_LINUX64_TEMPLATE) $(APPIMG_TOOL)
	mkdir -p $(BIN_DIR_LINUX64_IMG)
	cd $(BIN_DIR_LINUX64_IMG); tar -xf $(GAME_LINUX64_TEMPLATE_NAME)
	cat $(BIN_DIR_LINUX64_IMG)/squashfs-root/usr/bin/love $(GAME) > $(BIN_DIR_LINUX64_IMG)/squashfs-root/usr/bin/backdoor
	chmod +x $(BIN_DIR_LINUX64_IMG)/squashfs-root/usr/bin/backdoor
	cp $(IMGUI_LIB) $(BIN_DIR_LINUX64_IMG)/squashfs-root/usr/bin
	chmod +x $(BIN_DIR_LINUX64_IMG)/squashfs-root/AppRun
	cd $(BIN_DIR_LINUX64_IMG); ./$(APPIMG_TOOL_NAME) squashfs-root
	mv $(BIN_DIR_LINUX64_IMG)/backdoor-x86_64.AppImage $(BIN_DIR_LINUX64)
	rm -rf $(BIN_DIR_LINUX64_IMG)

## Windows build

$(LOVE_WIN32): $(GAME)
	mkdir -p $(BIN_DIR_WIN32_DEPS)
	wget -O $(LOVE_WIN32) https://bitbucket.org/rude/love/downloads/love-11.1-win32.zip

$(IMGUI_DLL):
	mkdir -p $(BIN_DIR_WIN32_DEPS)
	wget -O $(IMGUI_DLL) https://uspgamedev.org/downloads/libs/windows/x86/imgui.dll

$(LUAJIT_DLL):
	mkdir -p $(BIN_DIR_WIN32_DEPS)
	wget -O $(LUAJIT_DLL) https://uspgamedev.org/downloads/libs/windows/x86/lua51.dll

$(GAME_WIN32): $(GAME) $(IMGUI_DLL) $(LUAJIT_DLL) $(LOVE_WIN32)
	unzip $(LOVE_WIN32) -d $(BIN_DIR_WIN32)
	mv $(BIN_DIR_WIN32)/love-11.1.0-win32 $(BIN_DIR_WIN32_PACKAGE)
	cp $(IMGUI_DLL) $(LUAJIT_DLL) $(BIN_DIR_WIN32_PACKAGE)
	cat $(BIN_DIR_WIN32_PACKAGE)/love.exe $(GAME) > $(BIN_DIR_WIN32_PACKAGE)/backdoor.exe
	rm $(BIN_DIR_WIN32_PACKAGE)/love.exe $(BIN_DIR_WIN32_PACKAGE)/lovec.exe
	zip -r $(GAME_WIN32) $(BIN_DIR_WIN32_PACKAGE)
	rm -rf $(BIN_DIR_WIN32_PACKAGE)

## Deploy


## CLEAN UP

.PHONY: clean
clean:
	rm -rf $(DEPENDENCIES)

.PHONY: purge
purge: clean
	rm -rf externals/*

