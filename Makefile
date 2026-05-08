LANG ?= rust
REPO ?= github.com:tree-sitter/tree-sitter-$(LANG)
CC = gcc
UNAME := $(shell uname)
CODESIGN_IDENTITY ?= Developer ID Application: Unstable Build, LLC. (YYZRWD888J)
TAR = $(LANG).tar.gz
LIB = pkg/lib/tree-sitter.so pkg/lib/highlights.scm

# Resolve a tree-sitter CLI: prefer one already on PATH, then common install
# locations (homebrew, cargo). Used by recipes that NEEDS_GENERATE.
TREE_SITTER := $(shell \
  command -v tree-sitter 2>/dev/null \
  || ls /opt/homebrew/bin/tree-sitter 2>/dev/null \
  || ls /usr/local/bin/tree-sitter 2>/dev/null \
  || ls $$HOME/.cargo/bin/tree-sitter 2>/dev/null)

.PHONY: dist clean default sign
default: $(TAR)

# ============================================================================
# Per-language overrides
#
# Each language needs these variables resolved:
#   REPO_DIR       — cloned directory name (default: tree-sitter-$(LANG))
#   PARSER_SOURCE  — directory containing src/parser.c (default: $(REPO_DIR))
#   QUERY_SOURCE   — file path to highlights.scm (auto-detected)
#   TAGS_SOURCE    — file path to tags.scm (auto-detected)
#   NEEDS_GENERATE — set to 1 if tree-sitter generate is required
# ============================================================================

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
REPO_DIR       = tree-sitter-$(LANG)
PARSER_SOURCE  = $(REPO_DIR)
NEEDS_GENERATE =

# ---------------------------------------------------------------------------
# Category 1: Hyphen/underscore repo directory mismatches
# LANG uses underscores, but the repo directory uses hyphens.
# ---------------------------------------------------------------------------
ifeq ($(LANG),c_sharp)
REPO_DIR = tree-sitter-c-sharp
endif
ifeq ($(LANG),embedded_template)
REPO_DIR = tree-sitter-embedded-template
endif
ifeq ($(LANG),git_config)
REPO_DIR = tree-sitter-git-config
endif
ifeq ($(LANG),git_rebase)
REPO_DIR = tree-sitter-git-rebase
endif
ifeq ($(LANG),glimmer_javascript)
REPO_DIR = tree-sitter-glimmer-javascript
endif
ifeq ($(LANG),glimmer_typescript)
REPO_DIR = tree-sitter-glimmer-typescript
endif
ifeq ($(LANG),godot_resource)
REPO_DIR = tree-sitter-godot-resource
endif
ifeq ($(LANG),haskell_persistent)
REPO_DIR = tree-sitter-haskell-persistent
endif
ifeq ($(LANG),janet_simple)
REPO_DIR = tree-sitter-janet-simple
endif
ifeq ($(LANG),nim_format_string)
REPO_DIR = tree-sitter-nim-format-string
endif
ifeq ($(LANG),poe_filter)
REPO_DIR = tree-sitter-poe-filter
endif
ifeq ($(LANG),robots_txt)
REPO_DIR = tree-sitter-robots-txt
endif
ifeq ($(LANG),ssh_config)
REPO_DIR = tree-sitter-ssh-config
endif
ifeq ($(LANG),wgsl_bevy)
REPO_DIR = tree-sitter-wgsl-bevy
endif

# ---------------------------------------------------------------------------
# Category 2: Renamed repo directories (lang name ≠ repo suffix)
# ---------------------------------------------------------------------------
ifeq ($(LANG),gomod)
REPO_DIR = tree-sitter-go-mod
endif
ifeq ($(LANG),gosum)
REPO_DIR = tree-sitter-go-sum
endif
ifeq ($(LANG),gowork)
REPO_DIR = tree-sitter-go-work
endif
ifeq ($(LANG),gpg)
REPO_DIR = tree-sitter-gpg-config
endif

# ---------------------------------------------------------------------------
# Category 3: Multi-parser repos — parser under a subdirectory
# ---------------------------------------------------------------------------

# tree-sitter-csv: csv, psv, tsv
ifeq ($(LANG),csv)
PARSER_SOURCE = $(REPO_DIR)/csv
endif
ifeq ($(LANG),psv)
REPO_DIR = tree-sitter-csv
PARSER_SOURCE = $(REPO_DIR)/psv
endif
ifeq ($(LANG),tsv)
REPO_DIR = tree-sitter-csv
PARSER_SOURCE = $(REPO_DIR)/tsv
endif

# tree-sitter-sfapex: apex, sflog, soql, sosl
ifeq ($(LANG),apex)
REPO_DIR = tree-sitter-sfapex
PARSER_SOURCE = $(REPO_DIR)/apex
endif
ifeq ($(LANG),sflog)
REPO_DIR = tree-sitter-sfapex
PARSER_SOURCE = $(REPO_DIR)/sflog
endif
ifeq ($(LANG),soql)
REPO_DIR = tree-sitter-sfapex
PARSER_SOURCE = $(REPO_DIR)/soql
endif
ifeq ($(LANG),sosl)
REPO_DIR = tree-sitter-sfapex
PARSER_SOURCE = $(REPO_DIR)/sosl
endif

# tree-sitter-php: php, php_only
ifeq ($(LANG),php)
PARSER_SOURCE = $(REPO_DIR)/php
endif
ifeq ($(LANG),php_only)
REPO_DIR = tree-sitter-php
PARSER_SOURCE = $(REPO_DIR)/php_only
endif

# tree-sitter-typescript: typescript, tsx
ifeq ($(LANG),typescript)
PARSER_SOURCE = $(REPO_DIR)/typescript
endif
ifeq ($(LANG),tsx)
REPO_DIR = tree-sitter-typescript
PARSER_SOURCE = $(REPO_DIR)/tsx
endif

# tree-sitter-fsharp: fsharp
ifeq ($(LANG),fsharp)
PARSER_SOURCE = $(REPO_DIR)/fsharp
endif

# tree-sitter-xml: xml, dtd
ifeq ($(LANG),xml)
PARSER_SOURCE = $(REPO_DIR)/xml
endif
ifeq ($(LANG),dtd)
REPO_DIR = tree-sitter-xml
PARSER_SOURCE = $(REPO_DIR)/dtd
endif

# tree-sitter-markdown: markdown, markdown_inline
ifeq ($(LANG),markdown)
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-markdown
endif
ifeq ($(LANG),markdown_inline)
REPO_DIR = tree-sitter-markdown
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-markdown-inline
endif

# tree-sitter-jinja: jinja, jinja_inline
ifeq ($(LANG),jinja)
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-jinja
endif
ifeq ($(LANG),jinja_inline)
REPO_DIR = tree-sitter-jinja
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-jinja_inline
endif

# ---------------------------------------------------------------------------
# Category 4: Grammars under grammars/* subdirectory
# ---------------------------------------------------------------------------

# tree-sitter-ocaml: grammars/ocaml, grammars/interface
ifeq ($(LANG),ocaml)
PARSER_SOURCE = $(REPO_DIR)/grammars/ocaml
endif
ifeq ($(LANG),ocaml_interface)
REPO_DIR = tree-sitter-ocaml
PARSER_SOURCE = $(REPO_DIR)/grammars/interface
endif

# tree-sitter-prolog: grammars/prolog, grammars/problog
ifeq ($(LANG),prolog)
PARSER_SOURCE = $(REPO_DIR)/grammars/prolog
endif
ifeq ($(LANG),problog)
REPO_DIR = tree-sitter-prolog
PARSER_SOURCE = $(REPO_DIR)/grammars/problog
endif

# ---------------------------------------------------------------------------
# Category 5: Dialects — parser under dialects/$(LANG)/src
# ---------------------------------------------------------------------------

# tree-sitter-hcl: top-level (hcl) + dialects/terraform
ifeq ($(LANG),terraform)
REPO_DIR = tree-sitter-hcl
PARSER_SOURCE = $(REPO_DIR)/dialects/terraform
endif

# tree-sitter-go-template: top-level (gotmpl) + dialects/helm
ifeq ($(LANG),gotmpl)
REPO_DIR = tree-sitter-go-template
endif
ifeq ($(LANG),helm)
REPO_DIR = tree-sitter-go-template
PARSER_SOURCE = $(REPO_DIR)/dialects/helm
endif

# ---------------------------------------------------------------------------
# Category 6: Non-standard repo roots (not tree-sitter-*)
# ---------------------------------------------------------------------------

# v-analyzer: parser at v-analyzer/tree_sitter_v/src
ifeq ($(LANG),v)
REPO_DIR = v-analyzer
PARSER_SOURCE = $(REPO_DIR)/tree_sitter_v
endif

# superhtml: repo cloned as "superhtml", parser at superhtml/tree-sitter-superhtml/src
ifeq ($(LANG),superhtml)
REPO_DIR = superhtml
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-superhtml
endif

# ebnf: repo cloned as "ebnf", parser at ebnf/crates/tree-sitter-ebnf/src
ifeq ($(LANG),ebnf)
REPO_DIR = ebnf
PARSER_SOURCE = $(REPO_DIR)/crates/tree-sitter-ebnf
endif

# ziggy: repo cloned as "ziggy"
ifeq ($(LANG),ziggy)
REPO_DIR = ziggy
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-ziggy
endif
ifeq ($(LANG),ziggy_schema)
REPO_DIR = ziggy
PARSER_SOURCE = $(REPO_DIR)/tree-sitter-ziggy-schema
endif

# ---------------------------------------------------------------------------
# Category 7: Repos that need tree-sitter generate (no parser.c checked in)
# ---------------------------------------------------------------------------
ifeq ($(LANG),latex)
NEEDS_GENERATE = 1
endif
ifeq ($(LANG),perl)
NEEDS_GENERATE = 1
endif
ifeq ($(LANG),pod)
NEEDS_GENERATE = 1
endif
ifeq ($(LANG),sql)
NEEDS_GENERATE = 1
endif
ifeq ($(LANG),swift)
NEEDS_GENERATE = 1
endif

# ============================================================================
# Query source resolution
#
# Priority:
#   1. $(PARSER_SOURCE)/queries/highlights.scm          (standard)
#   2. $(REPO_DIR)/queries/highlights.scm               (top-level in repo)
#   3. $(REPO_DIR)/queries/$(LANG)/highlights.scm       (namespaced in repo)
#   4. nvim-treesitter/runtime/queries/$(LANG)/highlights.scm (fallback)
# ============================================================================
QUERY_SOURCE = $(shell \
  if [ -f "$(PARSER_SOURCE)/queries/highlights.scm" ]; then \
    echo "$(PARSER_SOURCE)/queries"; \
  elif [ -f "$(REPO_DIR)/queries/highlights.scm" ]; then \
    echo "$(REPO_DIR)/queries"; \
  elif [ -f "$(REPO_DIR)/queries/$(LANG)/highlights.scm" ]; then \
    echo "$(REPO_DIR)/queries/$(LANG)"; \
  elif [ -f "nvim-treesitter/runtime/queries/$(LANG)/highlights.scm" ]; then \
    echo "nvim-treesitter/runtime/queries/$(LANG)"; \
  fi)

TAGS_SOURCE = $(shell \
  if [ -f "$(PARSER_SOURCE)/queries/tags.scm" ]; then \
    echo "$(PARSER_SOURCE)/queries/tags.scm"; \
  elif [ -f "$(REPO_DIR)/queries/tags.scm" ]; then \
    echo "$(REPO_DIR)/queries/tags.scm"; \
  elif [ -f "$(REPO_DIR)/queries/$(LANG)/tags.scm" ]; then \
    echo "$(REPO_DIR)/queries/$(LANG)/tags.scm"; \
  fi)

# ============================================================================
# Derived variables
# ============================================================================
SRC = $(sort $(LANG) tools $(REPO_DIR))

# ============================================================================
# Rules
# ============================================================================

$(SRC):
	mkdir -p pkg/bin pkg/lib $(LANG) tools
	-git submodule add $(REPO)

$(LIB): $(SRC)
	cd $(REPO_DIR) && git reset --hard
ifdef NEEDS_GENERATE
	@if [ -z "$(TREE_SITTER)" ]; then \
		echo "error: tree-sitter CLI not found on PATH or in /opt/homebrew/bin, /usr/local/bin, ~/.cargo/bin"; \
		echo "       install via 'brew install tree-sitter' or 'cargo install tree-sitter-cli'"; \
		exit 1; \
	fi
	cd $(PARSER_SOURCE) && $(TREE_SITTER) generate
	@# Ensure tree_sitter/array.h exists (some scanners depend on it but generate doesn't produce it)
	@if [ ! -f "$(PARSER_SOURCE)/src/tree_sitter/array.h" ] && [ -f "tree-sitter-bass/src/tree_sitter/array.h" ]; then \
		cp tree-sitter-bass/src/tree_sitter/array.h $(PARSER_SOURCE)/src/tree_sitter/array.h; \
	fi
endif
	$(CC) -o $(REPO_DIR)/parser.so -I$(PARSER_SOURCE)/src $(PARSER_SOURCE)/src/*.c -Os -bundle -arch arm64 -arch x86_64
	cp $(REPO_DIR)/parser.so pkg/lib/tree-sitter.so
	@# Expand highlights — inlines any nvim-treesitter `; inherits:`
	@# chain so the shipped query is self-contained. PRIMARY_QUERY_DIR
	@# is the auto-detected QUERY_SOURCE; the script walks parents from
	@# nvim-treesitter when needed.
	PRIMARY_QUERY_DIR="$(QUERY_SOURCE)" tools/expand-inherits.sh highlights $(LANG) > pkg/lib/highlights.scm \
		|| (rm -f pkg/lib/highlights.scm; false)
	@# License aggregation
	@touch pkg/lib/LICENSE
	@-echo '# $(REPO)\n' >> pkg/lib/LICENSE
	@-cat $(REPO_DIR)/LICENSE* >> pkg/lib/LICENSE
	@-echo "================================================================================\n\n" >> pkg/lib/LICENSE
	@# Copy tags.scm if available
	@-if [ -n "$(TAGS_SOURCE)" ]; then cp "$(TAGS_SOURCE)" pkg/lib; fi
	@# Expand additional queries from nvim-treesitter (with inherits chains).
	@cd nvim-treesitter && git reset --hard
	@PRIMARY_QUERY_DIR="$(QUERY_SOURCE)" tools/expand-inherits.sh indents $(LANG) > pkg/lib/indents.scm 2>/dev/null \
		|| rm -f pkg/lib/indents.scm
	@PRIMARY_QUERY_DIR="$(QUERY_SOURCE)" tools/expand-inherits.sh folds   $(LANG) > pkg/lib/folds.scm   2>/dev/null \
		|| rm -f pkg/lib/folds.scm
	@PRIMARY_QUERY_DIR="$(QUERY_SOURCE)" tools/expand-inherits.sh locals  $(LANG) > pkg/lib/locals.scm  2>/dev/null \
		|| rm -f pkg/lib/locals.scm
	@-echo '\n\n# https://github.com/nvim-treesitter/nvim-treesitter\n' >> pkg/lib/LICENSE
	@-cat nvim-treesitter/LICENSE >> pkg/lib/LICENSE
	@# Copy any local query overrides
	@-cp src/*.scm pkg/lib 2>/dev/null || true

ifeq ($(UNAME),Darwin)
sign: $(LIB)
	codesign --force --options runtime --sign "$(CODESIGN_IDENTITY)" pkg/lib/tree-sitter.so
else
sign: $(LIB)
	@echo "Skipping codesign (not on macOS)"
endif

$(TAR): sign
	cd pkg && tar -czvf ../$(LANG).tar.gz .

dist: $(TAR)
	@ ./dist.sh

clean:
	rm -rf *.tar.gz
	rm -rf pkg
	mkdir -p pkg/bin pkg/lib $(LANG) tools

# ============================================================================
# Verification
#
# Asserts that the produced pkg/lib/highlights.scm has been fully
# expanded — i.e. it does not begin with `; inherits:` and is non-trivial.
# Use after `make` (or in CI) to catch new languages that slip through
# the expander unnoticed.
# ============================================================================
.PHONY: verify-inherits
verify-inherits:
	@if [ ! -f pkg/lib/highlights.scm ]; then \
		echo "verify-inherits: pkg/lib/highlights.scm missing for $(LANG)" >&2; exit 1; \
	fi
	@if grep -Eq '^[[:space:]]*;[[:space:]]*inherits[[:space:]]*:' pkg/lib/highlights.scm; then \
		echo "verify-inherits: $(LANG) highlights.scm still contains an unexpanded '; inherits:' line" >&2; \
		exit 1; \
	fi
	@lines=$$(wc -l < pkg/lib/highlights.scm); \
	if [ "$$lines" -le 5 ]; then \
		echo "verify-inherits: $(LANG) highlights.scm has only $$lines lines (likely empty/unexpanded)" >&2; \
		exit 1; \
	fi
	@echo "verify-inherits: $(LANG) ok"
