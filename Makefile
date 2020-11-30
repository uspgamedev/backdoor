
GAME_DIR=game
BIN_DIR=bin
LIBS_DIR=$(GAME_DIR)/libs
GAME=$(BIN_DIR)/backdoor.love

DEPLOY_SITE=https://usp.game.dev.br
DEPLOY_PATH=downloads/projects/backdoor
DEPLOY_URL=$(DEPLOY_SITE)/$(DEPLOY_PATH)

BIN_DIR_WIN32=$(BIN_DIR)/win32
BIN_DIR_WIN32_PACKAGE=$(BIN_DIR_WIN32)/backdoor
BIN_DIR_WIN32_DEPS=$(BIN_DIR_WIN32)/deps
LOVE_WIN32=$(BIN_DIR_WIN32_DEPS)/love-11.3-win32.zip
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

BIN_DIR_OSX=$(BIN_DIR)/osx
GAME_OSX_APP=$(BIN_DIR_OSX)/backdoor.app
GAME_OSX_TEMPLATE_NAME=backdoor-osx-template.zip
GAME_OSX_TEMPLATE_URL=$(DEPLOY_URL)/$(GAME_OSX_TEMPLATE_NAME)
GAME_OSX_TEMPLATE=$(BIN_DIR_OSX)/$(GAME_OSX_TEMPLATE_NAME)
GAME_OSX=$(BIN_DIR_OSX)/backdoor-osx.zip

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

IMGUI_LIB=$(GAME_DIR)/imgui.so
IMGUI_DLL=$(BIN_DIR_WIN32_DEPS)/imgui.dll
LUAJIT_DLL=$(BIN_DIR_WIN32_DEPS)/lua51.dll
IMGUI_REPO=externals/love-imgui
IMGUI_BUILD_DIR=externals/love-imgui/build
IMGUI_BUILD_MAKEFILE=$(IMGUI_BUILD_DIR)/Makefile
IMGUI_BINARY=$(IMGUI_BUILD_DIR)/imgui.so

CPML_LIB=$(LIBS_DIR)/cpml
CPML_REPO=externals/cpml

DKJSON_LIB=$(LIBS_DIR)/dkjson.lua

LIBS=$(LUX_LIB) $(STEAMING_LIB) $(CPML_LIB) $(DKJSON_LIB) $(INPUT_LIB)
LIBS_ZIP=libs.zip

DEPENDENCIES=$(LIBS) $(IMGUI_LIB)

BUILD_TYPE=nightly

## MAIN TARGETS

all: $(DEPENDENCIES)
	love game --development $(FLAGS)

update:
	cd $(STEAMING_REPO); git fetch && git reset --hard origin/master
	cd $(CPML_REPO); git fetch && git reset --hard origin/master
	cd $(IMGUI_REPO); git fetch && git reset --hard origin/master
	cd $(INPUT_REPO); git fetch && git reset --hard origin/backdoor
	cd $(LUX_REPO); git fetch && git reset --hard origin/dev
	git status externals

$(GAME): $(DEPENDENCIES)
	mkdir -p $(BIN_DIR)
	cd game; zip -r backdoor.love *
	mv game/backdoor.love $(GAME)

## LUX

$(LUX_LIB):
	git submodule update --init $(LUX_REPO)
	cp -r $(LUX_REPO)/lib/lux $(LUX_LIB)

## STEAMING

$(STEAMING_LIB):
	git submodule update --init $(STEAMING_REPO)
	mkdir $(STEAMING_LIB)
	cp -r $(STEAMING_MODULES) $(STEAMING_LIB)

## INPUT

$(INPUT_LIB):
	git submodule update --init $(INPUT_REPO)
	cp -r $(INPUT_REPO) $(INPUT_LIB)

## IMGUI

$(IMGUI_LIB): $(IMGUI_BINARY)
	cp -f $(IMGUI_BUILD_DIR)/imgui.so $(IMGUI_LIB)

$(IMGUI_BINARY): $(IMGUI_BUILD_MAKEFILE)
	$(MAKE) -C $(IMGUI_BUILD_DIR)

$(IMGUI_BUILD_MAKEFILE): $(IMGUI_BUILD_DIR)
	cd $(IMGUI_BUILD_DIR) && cmake ..

$(IMGUI_BUILD_DIR):
	git submodule update --init $(IMGUI_REPO)
	mkdir -p $(IMGUI_BUILD_DIR)

## CPML

$(CPML_LIB):
	git submodule update --init $(CPML_REPO)
	mkdir $(CPML_LIB)
	cp -r $(CPML_REPO)/modules $(CPML_LIB)
	cp -r $(CPML_REPO)/init.lua $(CPML_LIB)

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
	chmod +x $(BIN_DIR_LINUX64_IMG)/squashfs-root/AppRun
	cd $(BIN_DIR_LINUX64_IMG); ./$(APPIMG_TOOL_NAME) squashfs-root
	mv $(BIN_DIR_LINUX64_IMG)/backdoor-x86_64.AppImage $(BIN_DIR_LINUX64)
	rm -rf $(BIN_DIR_LINUX64_IMG)

## Windows build

$(LOVE_WIN32): $(GAME)
	mkdir -p $(BIN_DIR_WIN32_DEPS)
	curl -L -o $(LOVE_WIN32) https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip

$(IMGUI_DLL):
	mkdir -p $(BIN_DIR_WIN32_DEPS)
	wget -O $(IMGUI_DLL) https://uspgamedev.org/downloads/libs/windows/x86/imgui.dll

$(LUAJIT_DLL):
	mkdir -p $(BIN_DIR_WIN32_DEPS)
	wget -O $(LUAJIT_DLL) https://uspgamedev.org/downloads/libs/windows/x86/lua51.dll

$(GAME_WIN32): $(GAME) $(IMGUI_DLL) $(LUAJIT_DLL) $(LOVE_WIN32)
	unzip $(LOVE_WIN32) -d $(BIN_DIR_WIN32)
	mv $(BIN_DIR_WIN32)/love-11.3-win32 $(BIN_DIR_WIN32_PACKAGE)
	cp $(IMGUI_DLL) $(LUAJIT_DLL) $(BIN_DIR_WIN32_PACKAGE)
	cat $(BIN_DIR_WIN32_PACKAGE)/love.exe $(GAME) > $(BIN_DIR_WIN32_PACKAGE)/backdoor.exe
	rm $(BIN_DIR_WIN32_PACKAGE)/love.exe $(BIN_DIR_WIN32_PACKAGE)/lovec.exe
	zip -r $(GAME_WIN32) $(BIN_DIR_WIN32_PACKAGE)
	rm -rf $(BIN_DIR_WIN32_PACKAGE)

## OSX

$(GAME_OSX_TEMPLATE):
	mkdir -p $(BIN_DIR_OSX)
	wget -O $(GAME_OSX_TEMPLATE) $(GAME_OSX_TEMPLATE_URL)

$(GAME_OSX): $(GAME) $(GAME_OSX_TEMPLATE)
	cd $(BIN_DIR_OSX); unzip $(GAME_OSX_TEMPLATE_NAME)
	cp $(GAME) $(GAME_OSX_APP)/Contents/Resources
	zip -yr $(GAME_OSX) $(GAME_OSX_APP)
	rm -rf $(GAME_OSX_TEMPLATE)

## Libs

$(LIBS_ZIP): $(LIBS)
	zip -r $(LIBS_ZIP) $(LIBS)

## Deploy

.PHONY: export
export: $(GAME)

.PHONY: windows
windows: $(GAME_WIN32)

.PHONY: linux
linux: $(GAME_LINUX64)

.PHONY: osx
osx: $(GAME_OSX)

.PHONY: deploy-libs
deploy-libs: $(LIBS_ZIP)
	scp $(LIBS_ZIP) kazuo@uspgamedev.org:/var/docker-www/static/downloads/projects/backdoor/

.PHONY: deploy
deploy: $(GAME) $(GAME_WIN32) $(GAME_LINUX64) $(GAME_OSX)
	scp $(GAME) $(GAME_WIN32) $(GAME_LINUX64) $(GAME_OSX) kazuo@uspgamedev.org:/var/docker-www/static/downloads/projects/backdoor/$(BUILD_TYPE)/

## CLEAN UP

.PHONY: clean
clean:
	rm -rf $(DEPENDENCIES)

.PHONY: purge
purge: clean
	rm -rf externals/*
	rm -rf bin/*
