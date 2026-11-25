; Indents for Lua and luau, written by hand from nvim-treesitter's
; runtime/queries/lua/indents.scm (Apache-2.0). Upstream keeps the ")" of
; parameter lists out of @indent.end with Neovim's `#not-has-parent?`, which
; Rune does not evaluate: the pattern then also ended the indent after
; `function f(a, b)`. It lists the other parents of ")" instead, limited to the
; ones both grammars have, so luau's type_definition, tuple_type, function_type
; and empty_type parentheses no longer get @indent.end from it. Keep the
; patterns in upstream's order; only that pattern differs.

[
  (function_definition)
  (function_declaration)
  (field)
  (do_statement)
  (method_index_expression)
  (while_statement)
  (repeat_statement)
  (if_statement)
  "then"
  (for_statement)
  (return_statement)
  (table_constructor)
  (arguments)
] @indent.begin

[
  "end"
  "}"
  "]]"
] @indent.end

[
  (arguments
    ")" @indent.end)
  (parenthesized_expression
    ")" @indent.end)
  (ERROR
    ")" @indent.end)
]

(return_statement
  (expression_list
    (function_call))) @indent.dedent

[
  "end"
  "then"
  "until"
  "}"
  ")"
  "elseif"
  (elseif_statement)
  "else"
  (else_statement)
] @indent.branch

(comment) @indent.auto

(string) @indent.auto

(ERROR
  "function") @indent.begin
