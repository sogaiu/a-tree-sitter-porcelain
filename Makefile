# "Builds are programs"
#
# -- clojure.core folks
#
# “The principal lesson of Emacs is that a language for extensions
# should not be a mere “extension language”. It should be a real
# programming language, designed for writing and maintaining
# substantial programs. Because people will want to do that!”
#
# -- RMS
#
# Make is not a programming language!
#
# -- More than one programmer
#
# https://youtu.be/lgyOAiRtZGw?t=475

# XXX: process rules of makefiles
#
# https://make.mad-scientist.net/papers/rules-of-makefiles/

# XXX: additional targets?
#
#      * default?
#      * deps (or similar) to report versions of dependencies?
#
# https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html

# paths in this file are either:
#
# * relative to the grammar repository's root
# * absolute paths

ATSP_ROOT := .atsp

ATSP_CONF := $(ATSP_ROOT)/conf
ATSP_TASKS := $(ATSP_ROOT)/task
ATSP_UTILS := $(ATSP_ROOT)/util

BUILD_DIR_NAME ?= build/atsp
SO_BUILD_PATH := $(shell $(ATSP_UTILS)/so-build-path $(BUILD_DIR_NAME))

# XXX
TREE_SITTER_DIR ?= .tree-sitter
export TREE_SITTER_DIR
SO_INSTALL_DIR ?= $(shell $(ATSP_UTILS)/so-install-dir $(TREE_SITTER_DIR))
INSTALLED_SO_PATH := $(shell $(ATSP_UTILS)/installed-so-path \
                                          $(SO_INSTALL_DIR))

# XXX
TREE_SITTER_LIBDIR ?= $(TREE_SITTER_DIR)/lib
export TREE_SITTER_LIBDIR

PARSER_WASM := $(shell $(ATSP_UTILS)/wasm-name)

########################################################################

##############
# diagnostic #
##############

# XXX: using `set` can be a handy way to see what env vars got exported
.PHONY: dump
dump:
	$(ATSP_TASKS)/dump
	@echo
	$(ATSP_TASKS)/dump-languages

.PHONY: dump-languages
dump-languages:
	$(ATSP_TASKS)/dump-languages

##############
# list tasks #
##############
.PHONY: list
list:
	$(ATSP_TASKS)/list

######################
# create config.json #
######################
.PHONY: create-ts-config
create-ts-config:
	$(ATSP_TASKS)/create-ts-config

################
# symlink hack #
################

.PHONY: hack-symlink
hack-symlink:
	$(ATSP_TASKS)/hack-symlink

#################
# shared object #
#################

# XXX: tools that produces more than one output complicate things...
#
# https://www.gnu.org/software/automake/manual/html_node/Multiple-Outputs.html
#
# at a minimum, tree-sitter's generate subcommand can yield:
#
# * src/parser.c
# * src/node-types.json
#
# often it will also yield:
#
# * src/grammar.json
#
# before creating the other 2 files.  it can be instructed to skip
# creating src/grammar.json if it is provided a file path to a
# an existing grammar.json file.

# XXX: gen-src for convenient invocation
src/parser.c gen-src: grammar.js
	$(ATSP_TASKS)/gen-src

parser-source: src/parser.c

# XXX: build-so for convenient invocation
$(SO_BUILD_PATH) build-so: src/parser.c
	$(ATSP_TASKS)/build-so

# XXX: install-so for convenient invocation
$(INSTALLED_SO_PATH) install-so: $(SO_BUILD_PATH)
	$(ATSP_TASKS)/install-so

.PHONY: install
install: $(INSTALLED_SO_PATH)

# XXX: not quite sure about having two .PHONY lines here...
# XXX: uninstall-so is meant as an alias
.PHONY: uninstall
.PHONY: uninstall-so
uninstall uninstall-so:
	$(ATSP_TASKS)/uninstall-so

###############
### testing ###
###############

.PHONY: corpus-test
corpus-test: $(INSTALLED_SO_PATH)
	$(ATSP_TASKS)/corpus-test

###########################
### playground and wasm ###
###########################

.PHONY: playground
playground: $(PARSER_WASM)
	$(ATSP_TASKS)/playground

# XXX: build-wasm for convenient invocation
$(PARSER_WASM) build-wasm: src/parser.c
	$(ATSP_TASKS)/build-wasm

###################
### for cleanup ###
###################

.PHONY: clean
clean:
	$(ATSP_TASKS)/clean
