; Locals for the squirrel grammar, written by hand from tree-sitter-squirrel's
; queries/locals.scm (MIT). Upstream keeps method names out of the function
; definitions with `#not-has-ancestor?`, which Rune does not evaluate. A
; function nested in a method has the member_declaration at any depth above
; it, so no fixed nesting expresses it. The pattern is kept without the
; predicate: method names, which the next pattern already captures as
; methods, are also captured as functions, and so are functions nested in
; methods. Keep the patterns in upstream's order; only that pattern differs.

; Scopes

[
  (script)
  (class_declaration)
  (enum_declaration)
  (function_declaration)
  (attribute_declaration)

  (array)
  (block)
  (table)
  (anonymous_function)
  (parenthesized_expression)

  (if_statement)
  (else_statement)
  (while_statement)
  (do_while_statement)
  (switch_statement)
  (for_statement)
  (foreach_statement)
  (try_statement)
  (catch_statement)
] @scope


; References

[
  (identifier)
  (global_variable)
] @reference

; Definitions

(const_declaration
  . (identifier) @definition.constant)

(enum_declaration
  . (identifier) @definition.enum)

(member_declaration
  (identifier) @definition.field 
  . "=")

(table_slot
  . (identifier) @definition.field
  . ["=" ":"])

(function_declaration
  . (identifier) @definition.function)

(member_declaration
  (function_declaration
    . (identifier) @definition.method))

(class_declaration
  . (identifier) @definition.type)

(var_statement
  "var" . (identifier) @definition.variable)

(local_declaration
  (identifier) @definition.variable 
  . "=")
