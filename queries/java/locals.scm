; Locals for the java grammar, written by hand from nvim-treesitter's
; runtime/queries/java/locals.scm (Apache-2.0). Upstream limits the
; scoped_identifier import definition to imports with Neovim's
; `#has-ancestor?`, which Rune does not evaluate. The identifier can sit at
; any depth of nested scoped_identifiers, so no fixed nesting expresses it.
; The pattern is kept without the predicate: scoped_identifier only occurs
; in import, package, annotation and module declarations, so the identifiers
; of qualified package, annotation and module names also become import
; definitions. Keep the patterns in upstream's order; only that pattern
; differs.

; SCOPES
; declarations
(program) @local.scope

(class_declaration
  body: (_) @local.scope)

(record_declaration
  body: (_) @local.scope)

(enum_declaration
  body: (_) @local.scope)

(lambda_expression) @local.scope

(enhanced_for_statement) @local.scope

; block
(block) @local.scope

; if/else
(if_statement) @local.scope ; if+else

(if_statement
  consequence: (_) @local.scope) ; if body in case there are no braces

(if_statement
  alternative: (_) @local.scope) ; else body in case there are no braces

; try/catch
(try_statement) @local.scope ; covers try+catch, individual try and catch are covered by (block)

(catch_clause) @local.scope ; needed because `Exception` variable

; loops
(for_statement) @local.scope ; whole for_statement because loop iterator variable

(for_statement
  ; "for" body in case there are no braces
  body: (_) @local.scope)

(do_statement
  body: (_) @local.scope)

(while_statement
  body: (_) @local.scope)

; Functions
(constructor_declaration) @local.scope

(method_declaration) @local.scope

; DEFINITIONS
(package_declaration
  (identifier) @local.definition.namespace)

(class_declaration
  name: (identifier) @local.definition.type)

(record_declaration
  name: (identifier) @local.definition.type)

(enum_declaration
  name: (identifier) @local.definition.enum)

(method_declaration
  name: (identifier) @local.definition.method)

(local_variable_declaration
  declarator: (variable_declarator
    name: (identifier) @local.definition.var))

(enhanced_for_statement
  ; for (var item : items) {
  name: (identifier) @local.definition.var)

(formal_parameter
  name: (identifier) @local.definition.parameter)

(catch_formal_parameter
  name: (identifier) @local.definition.parameter)

(inferred_parameters
  (identifier) @local.definition.parameter) ; (x,y) -> ...

(lambda_expression
  parameters: (identifier) @local.definition.parameter) ; x -> ...

(scoped_identifier
  (identifier) @local.definition.import)

(field_declaration
  declarator: (variable_declarator
    name: (identifier) @local.definition.field))

; REFERENCES
(identifier) @local.reference

(type_identifier) @local.reference
