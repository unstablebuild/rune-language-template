; Indents for Nix, written by hand from nvim-treesitter's
; runtime/queries/nix/indents.scm (Apache-2.0). Upstream keeps attribute sets
; that are an if_expression's condition or branch out of @indent.begin with
; Neovim's `#not-has-parent?`, which Rune does not evaluate: the two patterns
; then also indented the body of `then { ... }` and `else { ... }` on their own
; lines a second time, on top of the if_expression's indent. They nest the set
; under each of its other possible parents instead. Keep the patterns in
; upstream's order; only those two patterns differ.

[
  (list_expression)
  (indented_string_expression)
  (let_expression)
  (if_expression)
  (binding)
  (parenthesized_expression)
] @indent.begin

[
  (apply_expression
    (attrset_expression) @indent.begin)
  (assert_expression
    (attrset_expression) @indent.begin)
  (binary_expression
    (attrset_expression) @indent.begin)
  (binding
    (attrset_expression) @indent.begin)
  (formal
    (attrset_expression) @indent.begin)
  (function_expression
    (attrset_expression) @indent.begin)
  (has_attr_expression
    (attrset_expression) @indent.begin)
  (inherit_from
    (attrset_expression) @indent.begin)
  (interpolation
    (attrset_expression) @indent.begin)
  (let_expression
    (attrset_expression) @indent.begin)
  (list_expression
    (attrset_expression) @indent.begin)
  (parenthesized_expression
    (attrset_expression) @indent.begin)
  (select_expression
    (attrset_expression) @indent.begin)
  (source_code
    (attrset_expression) @indent.begin)
  (unary_expression
    (attrset_expression) @indent.begin)
  (with_expression
    (attrset_expression) @indent.begin)
  (ERROR
    (attrset_expression) @indent.begin)
]

[
  (apply_expression
    (rec_attrset_expression) @indent.begin)
  (assert_expression
    (rec_attrset_expression) @indent.begin)
  (binary_expression
    (rec_attrset_expression) @indent.begin)
  (binding
    (rec_attrset_expression) @indent.begin)
  (formal
    (rec_attrset_expression) @indent.begin)
  (function_expression
    (rec_attrset_expression) @indent.begin)
  (has_attr_expression
    (rec_attrset_expression) @indent.begin)
  (inherit_from
    (rec_attrset_expression) @indent.begin)
  (interpolation
    (rec_attrset_expression) @indent.begin)
  (let_expression
    (rec_attrset_expression) @indent.begin)
  (list_expression
    (rec_attrset_expression) @indent.begin)
  (parenthesized_expression
    (rec_attrset_expression) @indent.begin)
  (select_expression
    (rec_attrset_expression) @indent.begin)
  (source_code
    (rec_attrset_expression) @indent.begin)
  (unary_expression
    (rec_attrset_expression) @indent.begin)
  (with_expression
    (rec_attrset_expression) @indent.begin)
  (ERROR
    (rec_attrset_expression) @indent.begin)
]

((binding
  "=" @indent.begin)
  (#set! indent.immediate 1))

(binding
  ";" @indent.end)

(parenthesized_expression
  ")" @indent.branch @indent.end)

(attrset_expression
  "}" @indent.branch @indent.end)

(rec_attrset_expression
  "}" @indent.branch @indent.end)

(list_expression
  "]" @indent.branch @indent.dedent)

(indented_string_expression
  "''" @indent.branch @indent.end .)

[
  "else"
  "in"
] @indent.branch

(let_expression
  body: (_) @indent.end @indent.dedent)

(string_fragment) @indent.ignore @indent.auto

(if_expression
  condition: (_) @indent.auto)

alternative: (if_expression) @indent.dedent

(interpolation) @indent.begin @indent.dedent

(interpolation
  "}" @indent.end @indent.branch)

(ERROR
  "then" @indent.begin)

(ERROR
  "then"
  .
  (formals) @indent.begin)

(ERROR
  "then"
  .
  (formals
    "}" @indent.branch @indent.end))

(ERROR
  "let") @indent.begin

(comment) @indent.ignore
