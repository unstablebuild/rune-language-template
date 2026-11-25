; Indents for the groovy grammar, written by hand from tree-sitter-groovy's
; queries/indents.scm (MIT). Upstream guards the for_loop pattern with
; Neovim's `#not-has-type?`, which Rune does not evaluate. The body now
; lists the node types a for_loop body can be other than (closure), instead
; of the wildcard. Keep the patterns in upstream's order; only that pattern
; differs.

[
  (closure)
  (map)
  (list)
  (argument_list)
  (parameter_list)
  (for_parameters)
] @indent.begin

; (function_definition "(" @indent.begin)

(closure "}" @indent.end)
(argument_list ")" @indent.end)
(for_parameters ")" @indent.end)
((for_loop
  body: [
    (access_op)
    (assertion)
    (assignment)
    (binary_op)
    (boolean_literal)
    (break)
    (class_definition)
    (continue)
    (declaration)
    (do_while_loop)
    (dotted_identifier)
    (for_in_loop)
    (for_loop)
    (function_call)
    (function_declaration)
    (function_definition)
    (groovy_import)
    (groovy_package)
    (identifier)
    (if_statement)
    (increment_op)
    (index)
    (juxt_function_call)
    (label)
    (list)
    (map)
    (null)
    (number_literal)
    (parenthesized_expression)
    (return)
    (string)
    (switch_statement)
    (ternary_op)
    (try_statement)
    (unary_op)
    (while_loop)
  ] @_body) @indent.begin)
; TODO: while, try

(list "]" @indent.end)
(map "]" @indent.end)

[ "}" ")" "]" ] @indent.branch
