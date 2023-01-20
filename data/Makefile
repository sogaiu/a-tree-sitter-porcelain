# XXX: if using with make via command line, it's important to set
#      certain environment variables as well as invoke from the
#      grammar repository root directory.
#
#      for example for the src/parser.c target:
#
#        ATSP_TS_PATH=tree-sitter \
#        ATSP_ABI=13 \
#        make -f .atsp/data/Makefile \
#          src/parser.c
#
#      specifically for build-wasm and playground, EMSDK* and PATH
#      also need to be set.
#
#      see bin/atsp for some details

# https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
# https://www.gnu.org/software/make/manual/html_node/Suffix-Rules.html
# delete default suffixes / clear implicit rules(?)
.SUFFIXES:

# XXX: many things below (e.g. ATSP_ABI) show up as a result of having
#      been made available as environment variables via whatever
#      invokes make with this Makefile (see note above for an example)

# iiuc, various sources suggest that commands that produce multiple
# outputs can cause issues with make (or redo).  there is some
# coverage here:
#
# https://www.gnu.org/software/automake/manual/html_node/Multiple-Outputs.html
#
# having read that a few times, i got the sense that work-arounds are
# being suggested.  it's not clear which situation applies to
# tree-sitter's generate subcommand.
#
# for the moment, i'm not going to consider this further.
src/parser.c: grammar.js
	mkdir -p src
	$(ATSP_TS_PATH) generate --abi $(ATSP_ABI) --no-bindings

src/grammar.json: grammar.js
	mkdir -p src
	$(ATSP_TS_PATH) generate --abi $(ATSP_ABI) --no-bindings

src/node-types.json: grammar.js
	mkdir -p src
	$(ATSP_TS_PATH) generate --abi $(ATSP_ABI) --no-bindings

# XXX: not listing scanner.(c|cc) as dependency because depending on
#      project it may not exist.  is this appropriate?
$(ATSP_BUILD_DIR)/$(ATSP_SO_NAME): src/parser.c
	mkdir -p $(ATSP_BUILD_DIR)
	cc -fPIC -c -Isrc src/parser.c -o $(ATSP_BUILD_DIR)/parser.o
	# May be compiling scanner.c
	if test -f src/scanner.c; then \
	  cc -fPIC -c -Isrc src/scanner.c -o $(ATSP_BUILD_DIR)/scanner.o; \
	fi
	# May be compiling scanner.cc
	if test -f src/scanner.cc; then \
	  c++ -fPIC -Isrc -c src/scanner.cc -o $(ATSP_BUILD_DIR)/scanner.o; \
	fi
	# Linking
	if test -f src/scanner.cc; then \
	  c++ -fPIC -shared $(ATSP_BUILD_DIR)/*.o \
              -o $(ATSP_BUILD_DIR)/$(ATSP_SO_NAME); \
	else \
	  cc -fPIC -shared $(ATSP_BUILD_DIR)/*.o \
             -o $(ATSP_BUILD_DIR)/$(ATSP_SO_NAME); \
	fi

# XXX: is it possible that generate might be invoked twice here?
$(ATSP_PARSER_NAME): src/parser.c src/grammar.json
	$(ATSP_TS_PATH) build-wasm

# XXX: should the recipe just copy to $(SO_INSTALL_PATH) instead of
#      the directory?
$(SO_INSTALL_PATH): $(ATSP_BUILD_DIR)/$(ATSP_SO_NAME)
	mkdir -p $(SO_INSTALL_DIR)
	cp $(ATSP_BUILD_DIR)/$(ATSP_SO_NAME) $(SO_INSTALL_DIR)

.PHONY: corpus-test
corpus-test: src/grammar.json $(SO_INSTALL_PATH)
	$(ATSP_TS_PATH) test

.PHONY: playground
playground: src/grammar.json $(ATSP_PARSER_NAME)
	$(ATSP_TS_PATH) playground
