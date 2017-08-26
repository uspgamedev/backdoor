
GAME_DIR=game

LUX_LIB=$(GAME_DIR)/lux
LUX_REPO=externals/luxproject

STEAMING_LIB=$(GAME_DIR)/steaming
STEAMING_REPO=externals/STEAMING
STEAMING_MODULES=$(STEAMING_REPO)/clean_template/font.lua \
								 $(STEAMING_REPO)/clean_template/res_manager.lua \
								 $(STEAMING_REPO)/clean_template/util.lua \
								 $(STEAMING_REPO)/clean_template/classes \
								 $(STEAMING_REPO)/clean_template/extra_libs

IMGUI_LIB=imgui.so
IMGUI_REPO=externals/love-imgui
IMGUI_BUILD_DIR=externals/love-imgui/build

CPML_LIB=$(GAME_DIR)/cpml
CPML_REPO=externals/cpml

DKJSON_LIB=$(GAME_DIR)/dkjson.lua

DEPENDENCIES=$(LUX_LIB) $(STEAMING_LIB) $(IMGUI_LIB) $(CPML_LIB) $(DKJSON_LIB)

## MAIN TARGETS

all: $(DEPENDENCIES)
	love game $(FLAGS)

update:
	cd $(LUX_REPO); git pull
	cd $(STEAMING_REPO); git pull

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

## IMGUI

$(IMGUI_LIB): $(IMGUI_BUILD_DIR)
	cd $(IMGUI_BUILD_DIR); cmake .. && $(MAKE)
	cp $(IMGUI_BUILD_DIR)/imgui.so $(IMGUI_LIB)

$(IMGUI_BUILD_DIR): $(IMGUI_REPO)
	mkdir $(IMGUI_BUILD_DIR)

$(IMGUI_REPO):
	git clone -b 0.8 https://github.com/slages/love-imgui.git $(IMGUI_REPO)

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

## CLEAN UP

.PHONY: clean
clean:
	rm -rf $(DEPENDENCIES)

.PHONY: purge
purge: clean
	rm -rf externals/*

