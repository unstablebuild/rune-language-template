; Highlights for the sproto grammar, written by hand from tree-sitter-sproto's
; queries/highlights.scm (MIT). Upstream expects a field's `type:` to be an
; identifier, but the grammar wraps it in a type_specifier, which holds no
; identifier for the builtin types. The pattern was impossible and the whole
; query failed to compile; it matches the type_specifier itself here, with
; the same builtin names. Keep the patterns in upstream's order; only that
; pattern differs.

(comment) @comment

[
  "."
  ":"
  "*"
  "request"
  "response"
] @keyword

(type_definition
  name: (identifier) @type)

(field_definition
  type: (type_specifier) @type.builtin
  (#any-of? @type.builtin "integer" "boolean" "string" "binary" "double"))

(protocol_definition
  name: (identifier) @function)

(field_definition
  name: (identifier) @property)

(field_definition
  tag: (integer) @number)
(protocol_definition
  tag: (integer) @number)

[
  "("
  ")"
  "{"
  "}"
] @punctuation.bracket

