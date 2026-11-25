; Indents for the snl grammar, written by hand from nvim-treesitter's
; runtime/queries/snl/indents.scm (Apache-2.0). Upstream guards four
; patterns with Neovim's `#not-kind-eq?`, which Rune does not evaluate.
; The if_statement and else_statement consequence is always a (statement)
; in this grammar, never a (block), so upstream's predicate always held and
; is dropped with no change in what matches. The while_statement and
; for_statement bodies list the node types a (statement) can hold other
; than (block), plus (comment), instead of the wildcard. Keep the patterns
; in upstream's order; only those four patterns differ.

[
  (field_declaration_list)
  (state_set)
  (state)
  (block)
  (member_decl)
] @indent.begin

(block
  "}" @indent.end)

[
  "else"
  "}"
] @indent.branch

(call_expression) @indent.begin

(call_expression
  ")" @indent.end)

(if_statement
  condition: (_) @indent.begin)

(if_statement
  consequence: (_) @_consequence) @indent.begin

(else_statement
  consequence: (_) @_consequence) @indent.begin

(while_statement
  body: (statement
    [
      (assignment_expression)
      (binary_expression)
      (break_statement)
      (c_code)
      (call_expression)
      (cast_expression)
      (char_literal)
      (comma_expr)
      (comment)
      (concatenated_string)
      (conditional_expression)
      (continue_statement)
      (exit_expression)
      (false)
      (field_expression)
      (for_statement)
      (identifier)
      (if_statement)
      (line_marker)
      (null)
      (number_literal)
      (parenthesized_expression)
      (pointer_expression)
      (preproc_call)
      (preproc_def)
      (preproc_function_def)
      (preproc_if)
      (preproc_ifdef)
      (preproc_include)
      (return_statement)
      (sizeof_expression)
      (state_statement)
      (string_literal)
      (subscript_expression)
      (true)
      (unary_expression)
      (update_expression)
      (while_statement)
    ] @_body)) @indent.begin

(for_statement
  body: (statement
    [
      (assignment_expression)
      (binary_expression)
      (break_statement)
      (c_code)
      (call_expression)
      (cast_expression)
      (char_literal)
      (comma_expr)
      (comment)
      (concatenated_string)
      (conditional_expression)
      (continue_statement)
      (exit_expression)
      (false)
      (field_expression)
      (for_statement)
      (identifier)
      (if_statement)
      (line_marker)
      (null)
      (number_literal)
      (parenthesized_expression)
      (pointer_expression)
      (preproc_call)
      (preproc_def)
      (preproc_function_def)
      (preproc_if)
      (preproc_ifdef)
      (preproc_include)
      (return_statement)
      (sizeof_expression)
      (state_statement)
      (string_literal)
      (subscript_expression)
      (true)
      (unary_expression)
      (update_expression)
      (while_statement)
    ] @_body)) @indent.begin

(init_declarator) @indent.begin

(transition
  condition: (_) @indent.begin)

[
  "#define"
  "#ifdef"
  "#if"
  "#else"
  "#endif"
] @indent.zero

[
  (preproc_arg)
  (string_literal)
] @indent.ignore

(comment) @indent.auto
