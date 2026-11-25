; Highlights for Tiger, written by hand from tree-sitter-tiger's
; queries/highlights.scm (MIT, per its Cargo.toml). Upstream guards its three
; builtin patterns (functions, types and `self`) with tree-sitter-highlight's
; `#is-not? local`, which Rune does not evaluate because it does not track
; locals. All three are kept without it: their `#match?` name lists keep them
; narrow, so only a local shadowing a builtin name gets mis-painted. Upstream
; orders the file for a first-match-wins highlighter, so in Rune the later
; function_call, type_identifier and identifier patterns paint over them
; anyway. Keep the patterns in upstream's order; only those three predicates
; differ.

; Built-ins {{{
((function_call
  function: (identifier) @function.builtin)
  (#match? @function.builtin "^(chr|concat|exit|flush|getchar|not|ord|print|print_err|print_int|size|strcmp|streq|substring)$"))

((type_identifier) @type.builtin
  (#match? @type.builtin "^(int|string|Object)$"))

((identifier) @variable.builtin
  (#match? @variable.builtin "^self$"))
; }}}

; Keywords {{{
[
 "function"
 "method"
 "primitive"
] @keyword.function

[
  "do"
  "for"
  "to"
  "while"
] @keyword.repeat

[
 "new"
] @keyword.constructor


[
  "import"
] @include

[
  "array"
  (break_expression)
  "else"
  "end"
  "if"
  "in"
  "let"
  "of"
  "then"
  "type"
  "var"

  "class"
  "extends"

  "_cast"
  "_chunks"
  "_exp"
  "_lvalue"
  "_namety"
] @keyword
; }}}

; Operators {{{
(operator) @operator

[
 ","
 ";"
 ":"
 "."
] @punctuation.delimiter

[
 "("
 ")"
 "["
 "]"
 "{"
 "}"
] @punctuation.bracket
; }}}

; Functions and methods {{{
(function_call
  function: (identifier) @function)
(function_declaration
  name: (identifier) @function)
(primitive_declaration
  name: (identifier) @function)

(method_call
  method: (identifier) @method)
(method_declaration
  name: (identifier) @method)

(parameters
  name: (identifier) @parameter)
; }}}

; Declarations {{{
(import_declaration
  file: (string_literal) @string.special.path)
; }}}

; Literals {{{
(nil_literal) @constant.builtin
(integer_literal) @number
(string_literal) @string
(escape_sequence) @string.escape
; }}}

; Misc {{{
(comment) @comment

(type_identifier) @type
(field_identifier) @property
(identifier) @variable
; }}}

; vim: sw=2 foldmethod=marker
