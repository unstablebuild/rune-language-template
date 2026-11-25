; Indents for the swift grammar, written by hand from tree-sitter-swift's
; queries/indents.scm (MIT). Upstream guards the attributed
; function_declaration pattern with Neovim's `#not-kind-eq?`, which Rune
; does not evaluate. Neovim rejects a match only when every node captured as
; @indent.branch is a (type_parameters) or a (parameter), which happens only
; when the modifiers hold nothing but the attribute and the first named node
; after them is one of those two, as in `@attr func +<T>(...)`. The pattern
; is split in two: the first lists the nodes that can follow the modifiers
; other than those two, and the second captures those two only when the
; modifiers hold more than the attribute. Keep the patterns in upstream's
; order; only that pattern differs.

; format-ignore
[
  ; ... refers to the section that will get affected by this indent.begin capture
  (protocol_body)               ; protocol Foo { ... }
  (class_body)                  ; class Foo { ... }
  (enum_class_body)             ; enum Foo { ... }
  (function_declaration)        ; func Foo (...) {...}
  (init_declaration)            ; init(...) {...}
  (deinit_declaration)          ; deinit {...}
  (computed_property)           ; { ... }
  (subscript_declaration)       ; subscript Foo(...) { ... }

  (computed_getter)             ; get { ... }
  (computed_setter)             ; set { ... }

  (assignment)                  ; a = b

  (control_transfer_statement)  ; return ...
  (for_statement)
  (while_statement)
  (repeat_while_statement)
  (do_statement)
  (if_statement)
  (switch_statement)
  (guard_statement)

  (type_parameters)             ; x<Foo>
  (tuple_type)                  ; (...)
  (array_type)                  ; [String]
  (dictionary_type)             ; [Foo: Bar]

  (call_expression)             ; callFunc(...)
  (tuple_expression)            ; ( foo + bar )
  (array_literal)               ; [ foo, bar ]
  (dictionary_literal)          ; [ foo: bar, x: y ]
  (lambda_literal)
  (willset_didset_block)
  (willset_clause)
  (didset_clause)
] @indent.begin

(init_declaration) @indent.begin

(init_declaration
  [
    "init"
    "("
  ] @indent.branch)

; indentation for init parameters
(init_declaration
  ")" @indent.branch @indent.end)

(init_declaration
  (parameter) @indent.begin
  (#set! indent.immediate))

; @something(...)
(modifiers
  (attribute) @indent.begin)

(function_declaration
  (modifiers
    .
    (attribute)
    (_)* @indent.branch)
  .
  [
    "class"
    "func"
    "async"
    "("
    ")"
    "->"
    "!="
    "!=="
    "%"
    "%="
    "&"
    "*"
    "*="
    "+"
    "++"
    "+="
    "-"
    "--"
    "-="
    "/"
    "/="
    "<"
    "<<"
    "<="
    "="
    "=="
    "==="
    ">"
    ">="
    ">>"
    "^"
    "|"
    "~"
    (simple_identifier)
    (custom_operator)
    (bang)
    (attribute)
    (inheritance_modifier)
    (ownership_modifier)
    (property_behavior_modifier)
    (throws)
    (array_type)
    (dictionary_type)
    (existential_type)
    (function_type)
    (metatype)
    (opaque_type)
    (optional_type)
    (protocol_composition_type)
    (suppressed_constraint)
    (tuple_type)
    (type_modifiers)
    (type_pack_expansion)
    (type_parameter_pack)
    (user_type)
    (type_constraints)
    (function_body)
    (comment)
    (multiline_comment)
  ] @indent.branch)

(function_declaration
  (modifiers
    .
    (attribute)
    (_)+ @indent.branch)
  .
  [
    (type_parameters)
    (parameter)
  ] @indent.branch)

(ERROR
  [
    "<"
    "{"
    "("
    "["
  ]) @indent.begin

; if-elseif
(if_statement
  (if_statement) @indent.dedent)

; case Foo:
; default Foo:
; @attribute default Foo:
(switch_entry
  .
  _ @indent.branch)

(function_declaration
  ")" @indent.branch)

(type_parameters
  ">" @indent.branch @indent.end .)

(tuple_expression
  ")" @indent.branch @indent.end)

(value_arguments
  ")" @indent.branch @indent.end)

(tuple_type
  ")" @indent.branch @indent.end)

(modifiers
  (attribute
    ")" @indent.branch @indent.end))

[
  "}"
  "]"
] @indent.branch @indent.end

[
  ; (ERROR)
  (comment)
  (multiline_comment)
  (raw_str_part)
  (multi_line_string_literal)
] @indent.auto

(directive) @indent.ignore

