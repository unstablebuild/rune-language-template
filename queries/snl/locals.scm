; Locals for the snl grammar, written by hand from nvim-treesitter's
; runtime/queries/snl/locals.scm (Apache-2.0). Upstream marks parameters
; with Neovim's `#has-ancestor?`, which Rune does not evaluate. The
; identifier can sit at any depth below the param_decl, through nested
; declarators, so no fixed nesting expresses it, and without the predicate
; the pattern would make every identifier a parameter definition. That
; `(identifier) @local.definition.parameter` pattern is dropped. Keep the
; patterns in upstream's order; only that pattern differs.

; Functions definitions
(function_declarator
  declarator: (identifier) @local.definition.function)

(preproc_function_def
  name: (identifier) @local.definition.macro) @local.scope

(preproc_def
  name: (identifier) @local.definition.macro)

(init_declarator
  (declarator
    (identifier)) @local.definition.var)

(array_declarator
  (identifier) @local.definition.var)

; Struct
(member_decl
  (declarator
    (identifier)) @local.definition.field)

(structdef
  name: (identifier) @local.definition.type)

; References
((field_expression
  field: (identifier) @local.reference)
  (#set! reference.kind "field"))

((call_expression
  function: (identifier) @local.reference)
  (#set! reference.kind "call"))

((basetype
  (identifier) @local.reference)
  (#set! reference.kind "type"))

; SNL specific
(state_set
  name: (identifier) @local.definition)

(state
  name: (identifier) @local.definition)

(state_statement
  name: (identifier) @local.reference)

(transition
  name: (identifier) @local.reference)

(identifier) @local.reference

[
  (for_statement)
  (if_statement)
  (while_statement)
  (source_file)
  (block)
  (state_set)
  (state_block)
] @local.scope
