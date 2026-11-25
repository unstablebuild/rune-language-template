; Indents shared by the JavaScript-like grammars (glimmer_javascript here),
; written by hand from nvim-treesitter's runtime/queries/ecma/indents.scm
; (Apache-2.0). Upstream narrows five patterns with Neovim's `#not-kind-eq?`
; and `#not-has-parent?`, which Rune does not evaluate, so each matched every
; node of its shape. The arrow_function, assignment_expression,
; variable_declarator and if_statement patterns list the kinds their field can
; hold other than the excluded ones (statement_block, arrow_function,
; call_expression), so `=> {`, `x = () =>`, `const x = f(` and braced ifs no
; longer indent twice. The parenthesized_expression pattern, which keeps an if
; condition's ")" out of @indent.end, nests the expression under each of its
; other possible parents. The kinds come from tree-sitter-glimmer-javascript's
; node-types.json. Keep the patterns in upstream's order; only those five
; patterns differ.

[
  (arguments)
  (array)
  (binary_expression)
  (class_body)
  (export_clause)
  (formal_parameters)
  (named_imports)
  (object)
  (object_pattern)
  (parenthesized_expression)
  (return_statement)
  (statement_block)
  (switch_case)
  (switch_default)
  (switch_statement)
  (template_substitution)
  (ternary_expression)
] @indent.begin

(arguments
  (call_expression) @indent.begin)

(binary_expression
  (call_expression) @indent.begin)

(expression_statement
  (call_expression) @indent.begin)

(arrow_function
  body: [
    (array)
    (arrow_function)
    (assignment_expression)
    (augmented_assignment_expression)
    (await_expression)
    (binary_expression)
    (call_expression)
    (class)
    (false)
    (function_expression)
    (generator_function)
    (glimmer_template)
    (identifier)
    (member_expression)
    (meta_property)
    (new_expression)
    (null)
    (number)
    (object)
    (parenthesized_expression)
    (regex)
    (string)
    (subscript_expression)
    (super)
    (template_string)
    (ternary_expression)
    (this)
    (true)
    (unary_expression)
    (undefined)
    (update_expression)
    (yield_expression)
  ]) @indent.begin

(assignment_expression
  right: [
    (array)
    (assignment_expression)
    (augmented_assignment_expression)
    (await_expression)
    (binary_expression)
    (call_expression)
    (class)
    (false)
    (function_expression)
    (generator_function)
    (glimmer_template)
    (identifier)
    (member_expression)
    (meta_property)
    (new_expression)
    (null)
    (number)
    (object)
    (parenthesized_expression)
    (regex)
    (string)
    (subscript_expression)
    (super)
    (template_string)
    (ternary_expression)
    (this)
    (true)
    (unary_expression)
    (undefined)
    (update_expression)
    (yield_expression)
  ]) @indent.begin

(variable_declarator
  value: [
    (array)
    (assignment_expression)
    (augmented_assignment_expression)
    (await_expression)
    (binary_expression)
    (class)
    (false)
    (function_expression)
    (generator_function)
    (glimmer_template)
    (identifier)
    (member_expression)
    (meta_property)
    (new_expression)
    (null)
    (number)
    (object)
    (parenthesized_expression)
    (regex)
    (string)
    (subscript_expression)
    (super)
    (template_string)
    (ternary_expression)
    (this)
    (true)
    (unary_expression)
    (undefined)
    (update_expression)
    (yield_expression)
  ]) @indent.begin

(arguments
  ")" @indent.end)

(object
  "}" @indent.end)

(statement_block
  "}" @indent.end)

[
  (arguments
    (object))
  ")"
  "}"
  "]"
] @indent.branch

(statement_block
  "{" @indent.branch)

[
  (arguments
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (array
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (arrow_function
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (assignment_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (assignment_pattern
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (augmented_assignment_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (await_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (binary_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (call_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (class_heritage
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (computed_property_name
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (do_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (export_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (expression_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (field_definition
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (for_in_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (for_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (member_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (new_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (object_assignment_pattern
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (pair
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (parenthesized_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (return_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (sequence_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (spread_element
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (subscript_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (switch_case
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (switch_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (template_substitution
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (ternary_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (throw_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (unary_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (update_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (variable_declarator
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (while_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (with_statement
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (yield_expression
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
  (ERROR
    (parenthesized_expression
      "("
      (_)
      ")" @indent.end))
]

[
  "}"
  "]"
] @indent.end

(template_string) @indent.ignore

[
  (comment)
  (ERROR)
] @indent.auto

(if_statement
  consequence: [
    (break_statement)
    (class_declaration)
    (continue_statement)
    (debugger_statement)
    (do_statement)
    (empty_statement)
    (export_statement)
    (expression_statement)
    (for_in_statement)
    (for_statement)
    (function_declaration)
    (generator_function_declaration)
    (if_statement)
    (import_statement)
    (labeled_statement)
    (lexical_declaration)
    (return_statement)
    (switch_statement)
    (throw_statement)
    (try_statement)
    (variable_declaration)
    (while_statement)
    (with_statement)
  ] @indent.dedent) @indent.begin
