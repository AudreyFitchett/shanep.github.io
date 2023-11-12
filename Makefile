BUILD_DIR ?= ./build
SRC_DIR ?= ./src
STATIC_DIR ?= ./static
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
		REVEAL ?= ./vendor/asciidoctor-revealjs-linux
endif
ifeq ($(UNAME_S),Darwin)
		REVEAL ?= ./vendor/asciidoctor-revealjs-macos
endif

SRCS := $(patsubst $(SRC_DIR)/%, %,$(shell find $(SRC_DIR) -name *.adoc))
GRAPHS := $(patsubst $(SRC_DIR)/%, %,$(shell find $(SRC_DIR) -name *.dot))

DOCS := $(SRCS:%.adoc=$(BUILD_DIR)/%.html)
DOTS := $(GRAPHS:%.dot=$(SRC_DIR)/%.png)

# This rule will build a HTML file from an asciidoc file
# We remove the old file in the build directory to force live preview to reload
$(BUILD_DIR)/%.html: $(SRC_DIR)/%.adoc
	@rm -f $@
	$(if $(findstring slides,$<), $(REVEAL) -a data-uri $< -o $@ , asciidoctor -a data-uri -w -v $< -o $@)

# This rule will build a PNG file from a dot file
$(SRC_DIR)/%.png: $(SRC_DIR)/%.dot
	dot $< -Tpng -Gdpi=300 > $@

all: static-docs $(DOCS) $(DOTS)


static-docs:
	rsync -rupE $(STATIC_DIR)/ $(BUILD_DIR)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)