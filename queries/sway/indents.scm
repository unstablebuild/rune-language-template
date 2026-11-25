; Indents for the sway grammar, written by hand from tree-sitter-sway's
; queries/indents.scm (Apache-2.0). These are Helix-style captures
; (@indent, @outdent); Rune only applies @indent.* captures. Upstream guards
; the four patterns that indent the right side of assignment_expression,
; compound_assignment_expr, let_declaration and if_expression with
; `#not-same-line?`, which Rune does not evaluate. No query structure says
; whether two nodes start on the same line, so those four patterns and the
; comment describing them are dropped. Keep the patterns in upstream's order;
; only those four patterns differ.

[
  (use_list)
  (block)
  (match_block)
  (arguments)
  (parameters)
  (declaration_list)
  (field_declaration_list)
  (field_initializer_list)
  (struct_pattern)
  (tuple_pattern)
  (unit_expression)
  (enum_variant_list)
  (call_expression)
  (binary_expression)
  (field_expression)
  (tuple_expression)
  (array_expression)
  (where_clause)

  (token_tree)
] @indent

[
  "}"
  "]"
  ")"
] @outdent

; Some field expressions where the left part is a multiline expression are not
; indented by cargo fmt.
; Because this multiline expression might be nested in an arbitrary number of
; field expressions, this can only be matched using a Regex.
(field_expression
  value: (_) @val
  "." @outdent
  (#match? @val "(\\A[^\\n\\r]+\\([\\t ]*(\\n|\\r).*)|(\\A[^\\n\\r]*\\{[\\t ]*(\\n|\\r))")
)
