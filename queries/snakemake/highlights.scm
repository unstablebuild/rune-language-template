; inherits: python
; Highlights for Snakemake, written by hand from tree-sitter-snakemake's
; queries/snakemake/highlights.scm (MIT). Upstream limits the last pattern,
; directive labels such as `input` and `output` in Python code, to identifiers
; inside a directive's block with Neovim's `#has-ancestor?`, which Rune does
; not evaluate. The identifier can sit at any depth in the Python code of a
; `run:` block, so no fixed nesting matches it exactly. The pattern is kept
; without both predicates: `#any-of?` still limits it to the nine label names,
; so only those names used outside a directive block (an input function's
; `wildcards` parameter, a call to Python's `input()`) also get painted as
; labels. Keep the patterns in upstream's order; only those predicates differ.

; Compound directives
[
  "rule"
  "checkpoint"
  "module"
] @keyword

; Top level directives (eg. configfile, include)
(module
  (directive
    name: _ @keyword))

; Subordinate directives (eg. input, output)
body: (_
  (directive
    name: _ @label))

; rule/module/checkpoint names
(rule_definition
  name: (identifier) @type)

(module_definition
  name: (identifier) @type)

(checkpoint_definition
  name: (identifier) @type)

; Rule imports
(rule_import
  [
    "use"
    "rule"
    "from"
    "exclude"
    "as"
    "with"
  ] @keyword.import)

; Rule inheritance
(rule_inheritance
  "use" @keyword
  "rule" @keyword
  "with" @keyword)

; Wildcard names
(wildcard
  (identifier) @variable)

(wildcard
  (flag) @variable.parameter.builtin)

; builtin variables
((identifier) @variable.builtin
  (#any-of? @variable.builtin "checkpoints" "config" "gather" "rules" "scatter" "workflow"))

; References to directive labels in wildcard interpolations
; the #any-of? queries are moved above the #has-ancestor? queries to
; short-circuit the potentially expensive tree traversal, if possible
; see:
; https://github.com/nvim-treesitter/nvim-treesitter/pull/4302#issuecomment-1685789790
; directive labels in wildcard context
((wildcard
  (identifier) @label)
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))

((wildcard
  (attribute
    object: (identifier) @label))
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))

((wildcard
  (subscript
    value: (identifier) @label))
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))

; directive labels in block context (eg. within 'run:')
((identifier) @label
  (#any-of? @label "input" "jobid" "log" "output" "params" "resources" "rule" "threads" "wildcards"))
