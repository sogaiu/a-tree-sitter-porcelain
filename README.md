# A Tree Sitter Porcelein (atsp)

A hackable porcelain for tree-sitter grammar-related tasks.

## Status

Really early :)

## Idea

Use portions of `tree-sitter` which work in your situation, but
augment / customize / substitute as necessary.

Some things that seem achievable:

* Customize building of shared objects
  * Alternate compiler on Windows
    ([#1835](https://github.com/tree-sitter/tree-sitter/pull/1835))
  * Different flags for building
    ([#1518](https://github.com/tree-sitter/tree-sitter/issues/1518))
  * Include additional files (e.g. scanner-related)
    ([#1262](https://github.com/tree-sitter/tree-sitter/issues/1262))

* Alternative methods (non-Node.js) of generating `src/parser.c`:
  * Using quickjs to generate `grammar.json` from `grammar.js`:
  ([comment @ #465](https://github.com/tree-sitter/tree-sitter/issues/465#issuecomment-1371911897))
  * Feed `grammar.json` to `generate` subcommand:
  ([comment @ #1413](https://github.com/tree-sitter/tree-sitter/discussions/1413#discussioncomment-1414650))

* Customize playground
  * Color blind mode for playground
  ([#1714](https://github.com/tree-sitter/tree-sitter/issues/1714))
  * Rename query to highlighting
  ([#1305](https://github.com/tree-sitter/tree-sitter/issues/1305))
  ([#1495](https://github.com/tree-sitter/tree-sitter/pull/1495))
  * Playground with multiple languages
  ([#1777](https://github.com/tree-sitter/tree-sitter/discussions/1777))

* Customizing building of `.wasm` files when investigating Emscripten
  breakage
  ([#1829](https://github.com/tree-sitter/tree-sitter/issues/1829))

* Reduce / eliminate usage of `npm` to [avoid unnecessary
  churn](https://github.com/sogaiu/tree-sitter-clojure/pull/26#issuecomment-1186136996)

* Investigate / debug problems in scripts instead of binaries

## Setup

```
# assuming there's an existing grammar repository under ~/src
cd ~/src
cd tree-sitter-<lang-name>

# clone as .atsp inside the grammar repository
git clone https://github.com/sogaiu/a-tree-sitter-porcelain .atsp

# ensure .astp/conf has a line in it like: ATSP_LANG=<lang-name>
$VISUAL .atsp/conf

# need this to put `atsp` command on PATH
export PATH=$(pwd)/.atsp/bin:$PATH

# optionally setup bash completion
source .atsp/completion

# see a list of subcommands
atsp list
```

## What's In Here

* `bin` - contains wrapper program `atsp` for convenient task execution
* `conf` - contains settings specific to the grammar repository
* `task` - task scripts
* `util` - directory of utility scripts used by task scripts
* `README.md` - this README file

### `bin`

Add this directory to your PATH to make the wrapper script `atsp`
conveniently available for use.

### `conf`

The `conf` file is meant to contain just lines that look like:

```
ATSP_LANG=clojure
```

Other values that can be configured include:

* `ATSP_EMSDK` - path to emsdk
* `ATSP_ABI` - ABI version for `tree-sitter generate` to use (13 is good now)
* `ATSP_VERBOSE` - task script verbosity (1 for verbose)

### `task`

Each task script in `task` expresses a task one might carry out in the
course of working with a grammar repository such as:

* Generating parser source from `grammar.js`
* Cleaning up files and directories
* Starting the web playground

The scripts can be executed on their own but they can also be used as
subcommands from the `atsp` wrapper program.

### `util`

The `util` directory contains some scripts that allow reuse of
functionality.  The hope here was to reduce duplication.

## Linting Shell Scripts

To lint, run `shellcheck -x <name>` on the shell files in `task`
and `util` directories.

Invoke [`shellcheck`](https://github.com/koalaman/shellcheck) from
inside `task` or `util`.  I'm not sure its checking will function
correctly for "source"d files otherwise.

