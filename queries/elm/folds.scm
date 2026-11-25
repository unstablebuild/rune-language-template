; Folds for elm, written by hand from nvim-treesitter's
; runtime/queries/elm/folds.scm (Apache-2.0). Upstream excludes function calls
; directly inside a parenthesized_expr with Neovim's `#not-has-parent?`, which
; Rune does not evaluate. That pattern is spelled out instead as one branch per
; node type that can parent a function_call_expr in tree-sitter-elm's
; src/node-types.json, leaving parenthesized_expr out. Keep the patterns in
; upstream's order; only that predicate differs.

[
  (anonymous_function_expr
    (function_call_expr) @fold)
  (bin_op_expr
    (function_call_expr) @fold)
  (case_of_branch
    (function_call_expr) @fold)
  (case_of_expr
    (function_call_expr) @fold)
  (field
    (function_call_expr) @fold)
  (if_else_expr
    (function_call_expr) @fold)
  (let_in_expr
    (function_call_expr) @fold)
  (list_expr
    (function_call_expr) @fold)
  (tuple_expr
    (function_call_expr) @fold)
  (value_declaration
    (function_call_expr) @fold)
]

[
  (case_of_branch)
  (case_of_expr)
  (value_declaration)
  (type_declaration)
  (type_alias_declaration)
  (list_expr)
  (record_expr)
  (parenthesized_expr)
  (import_clause)+
] @fold
