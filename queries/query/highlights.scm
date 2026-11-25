; Highlights for query, written by hand from
; tree-sitter-query/queries/query/highlights.scm (Apache-2.0). Upstream matches
; with Neovim's `#lua-match?`, which Rune does not evaluate: each such pattern
; then painted every node it structurally matched. The 3 predicates now use
; `#match?` with the Lua patterns translated to RE2, matching the same text.
; Keep the patterns in upstream's order; only those predicates differ.

(string) @string

(escape_sequence) @string.escape

(capture
  (identifier) @type)

(predicate
  name: (identifier) @function.call)

(named_node
  name: (identifier) @variable)

(missing_node
  name: (identifier) @variable)

(field_definition
  name: (identifier) @variable.member)

(negated_field
  "!" @operator
  (identifier) @property)

(comment) @comment @spell

(quantifier) @operator

(predicate_type) @punctuation.special

"." @operator

[
  "["
  "]"
  "("
  ")"
] @punctuation.bracket

[
  ":"
  "/"
] @punctuation.delimiter

[
  "@"
  "#"
] @punctuation.special

(predicate
  "." @punctuation.special)

"_" @character.special

"MISSING" @keyword

((parameters
  (identifier) @number)
  (#match? @number "^[-+]?[0-9]+(.[0-9]+)?$"))

((program
  .
  (comment)*
  .
  (comment) @keyword.import @nospell)
  (#match? @keyword.import "^;+ *inherits *:"))

((program
  .
  (comment)*
  .
  (comment) @keyword.directive @nospell)
  (#match? @keyword.directive "^;+ *extends *$"))

((comment) @keyword.directive @nospell
  (#match? @keyword.directive "^;+\\s*format-ignore\\s*$"))

((predicate
  name: (identifier) @_name
  parameters: (parameters
    .
    (capture)?
    .
    (identifier) @property))
  (#eq? @_name "set"))

((predicate
  name: (identifier) @_name
  parameters: (parameters
    (string
      "\"" @string
      "\"" @string) @string.regexp))
  (#any-of? @_name "match" "not-match" "vim-match" "not-vim-match" "lua-match" "not-lua-match"))

((predicate
  name: (identifier) @_name
  parameters: (parameters
    (string
      "\"" @string
      "\"" @string) @string.regexp
    .
    (string) .))
  (#any-of? @_name "gsub" "not-gsub"))
