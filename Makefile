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

# uncomment the following line for tracing the execution of shell
# scripts that are associated with targets in this file

#SHELL = sh -x

# alternatively, use make from the grammar repository directory like:
#
#   make -f .atsp/Makefile <target> SHELL='sh -x'
#
# this should also work for atsp:
#
#   atsp <target> SHELL='sh -x'
#
# note that this will only work for targets that are basically shell
# scripts (which happens to be the case at the time of this writing).

ATSP_ROOT := .atsp

ATSP_CONF := $(ATSP_ROOT)/conf
ATSP_TASK := $(ATSP_ROOT)/task
ATSP_UTIL := $(ATSP_ROOT)/util

# XXX: could have a script that fetches a default value - reduce
#      duplication with .common script?
BUILD_DIR_NAME ?= build/atsp
SO_BUILD_PATH := $(shell $(ATSP_UTIL)/so-build-path $(BUILD_DIR_NAME))

# XXX
TREE_SITTER_DIR ?= .tree-sitter
# XXX: could be a bit more selective about where to do this as it's
#      not always relevant for each target
export TREE_SITTER_DIR
SO_INSTALL_DIR ?= $(shell $(ATSP_UTIL)/so-install-dir $(TREE_SITTER_DIR))
INSTALLED_SO_PATH := $(shell $(ATSP_UTIL)/installed-so-path \
                                          $(SO_INSTALL_DIR))

# XXX
TREE_SITTER_LIBDIR ?= $(TREE_SITTER_DIR)/lib
# XXX: could be a bit more selective about where to do this as it's
#      not always relevant for each target
export TREE_SITTER_LIBDIR

# XXX
ATSP_EMSDK ?= $(shell $(ATSP_UTIL)/emsdk-path)
# XXX: could be a bit more selective about where to do this as it's
#      not always relevant for each target
export ATSP_EMSDK

# XXX
TS_ABI ?= $(shell $(ATSP_UTIL)/abi)
# XXX: could be a bit more selective about where to do this as it's
#      not always relevant for each target
export TS_ABI

PARSER_WASM := $(shell $(ATSP_UTIL)/wasm-name)

########################################################################

##############
# diagnostic #
##############

# XXX: using `set` can be a handy way to see what env vars got exported
.PHONY: dump
dump:
	$(SHELL) $(ATSP_TASK)/dump
	@echo
	$(SHELL) $(ATSP_TASK)/dump-languages

.PHONY: dump-languages
dump-languages:
	$(SHELL) $(ATSP_TASK)/dump-languages

.PHONY: check
check:
	$(SHELL) $(ATSP_TASK)/check

##############
# list tasks #
##############
.PHONY: list
list:
	$(SHELL) $(ATSP_TASK)/list

######################
# create config.json #
######################
.PHONY: create-ts-config
create-ts-config:
	$(SHELL) $(ATSP_TASK)/create-ts-config

################
# symlink hack #
################

.PHONY: hack-symlink
hack-symlink:
	$(SHELL) $(ATSP_TASK)/hack-symlink

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
	$(SHELL) $(ATSP_TASK)/gen-src

parser-source: src/parser.c

# XXX: build-so for convenient invocation
$(SO_BUILD_PATH) build-so: src/parser.c
	$(SHELL) $(ATSP_TASK)/build-so

# XXX: install-so for convenient invocation
$(INSTALLED_SO_PATH) install-so: $(SO_BUILD_PATH)
	$(SHELL) $(ATSP_TASK)/install-so

.PHONY: install
install: $(INSTALLED_SO_PATH)

# XXX: not quite sure about having two .PHONY lines here...
# XXX: uninstall-so is meant as an alias
.PHONY: uninstall
.PHONY: uninstall-so
uninstall uninstall-so:
	$(SHELL) $(ATSP_TASK)/uninstall-so

###############
### testing ###
###############

.PHONY: corpus-test
corpus-test: $(INSTALLED_SO_PATH)
	$(SHELL) $(ATSP_TASK)/corpus-test

###########################
### playground and wasm ###
###########################

.PHONY: playground
playground: $(PARSER_WASM)
	$(SHELL) $(ATSP_TASK)/playground

# XXX: build-wasm for convenient invocation
$(PARSER_WASM) build-wasm: src/parser.c
	$(SHELL) $(ATSP_TASK)/build-wasm

###################
### for cleanup ###
###################

.PHONY: clean
clean:
	$(SHELL) $(ATSP_TASK)/clean
