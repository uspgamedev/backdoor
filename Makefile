
GAME_DIR=game

LUX_LIB=$(GAME_DIR)/lux
LUX_REPO=externals/luxproject

UFO_LIB=$(GAME_DIR)/ufo
UFO_REPO=externals/ufoproject

IMGUI_LIB=imgui.so
IMGUI_REPO=externals/love-imgui
IMGUI_BUILD_DIR=externals/love-imgui/build

DEPENDENCIES=$(LUX_LIB) $(UFO_LIB) $(IMGUI_LIB)

## MAIN TARGETS

all: $(DEPENDENCIES)
	love game

update:
	cd $(LUX_REPO); git pull
	cd $(UFO_REPO); git pull

## LUX

$(LUX_LIB): $(LUX_REPO)
	cp -r $(LUX_REPO)/lib/lux $(LUX_LIB)

$(LUX_REPO):
	git clone https://github.com/Kazuo256/luxproject.git $(LUX_REPO)

## UFO

$(UFO_LIB): $(UFO_REPO)
	cp -r $(UFO_REPO)/lib/ufo $(UFO_LIB)

$(UFO_REPO):
	git clone https://github.com/Kazuo256/ufoproject.git $(UFO_REPO)

## IMGUI

$(IMGUI_LIB): $(IMGUI_BUILD_DIR)
	cd $(IMGUI_BUILD_DIR); cmake .. && $(MAKE)
	cp $(IMGUI_BUILD_DIR)/imgui.so $(IMGUI_LIB)

$(IMGUI_BUILD_DIR): $(IMGUI_REPO)
	mkdir $(IMGUI_BUILD_DIR)

$(IMGUI_REPO):
	git clone -b 0.8 https://github.com/slages/love-imgui.git $(IMGUI_REPO)

## CLEAN UP

.PHONY: clean
clean:
	rm -rf $(DEPENDENCIES)

.PHONY: purge
purge: clean
	rm -rf externals/*

