; Highlights for Gleam, written by hand from tree-sitter-gleam's
; queries/highlights.scm (Apache-2.0). Upstream guards three patterns with
; tree-sitter-highlight's `#is-not? local`, which Rune does not evaluate
; because it does not track locals. The function_call and `|>` patterns are
; kept without the predicate: they only capture a callee, so only a call
; through a local variable is painted as a function. The field_access pattern
; that paints the record of `a.b` as a module is dropped: without the
; predicate it painted every local record variable, e.g. `user` in
; `user.name`, as a module. Keep the patterns in upstream's order; only those
; three patterns differ.

; Punctuation
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
  "<<"
  ">>"
] @punctuation.bracket
[
  "."
  ","
  ;; Controversial -- maybe some are operators?
  ":"
  "#"
  "="
  "->"
  ".."
  "-"
  "<-"
] @punctuation.delimiter

; Variables
(identifier) @variable
(discard) @comment.unused

; Comments
(module_comment) @comment
(statement_comment) @comment
(comment) @comment

; Constants
(constant
  name: (identifier) @constant)

; "Properties"
; Assumed to be intended to refer to a name for a field; something that comes
; before ":" or after "."
; e.g. record field names, tuple indices, names for named arguments, etc
(label) @property
(tuple_access
  index: (integer) @property)

; Modules
(module) @module
(import alias: (identifier) @module)
(remote_type_identifier
  module: (identifier) @module)
(remote_constructor_name
  module: (identifier) @module)

; Functions
(unqualified_import (identifier) @function)
(unqualified_import "type" (type_identifier) @type)
(unqualified_import (type_identifier) @constructor)
(function
  name: (identifier) @function)
(external_function
  name: (identifier) @function)
(function_parameter
  name: (identifier) @variable.parameter)
((function_call
   function: (identifier) @function))
((binary_expression
   operator: "|>"
   right: (identifier) @function))

; TODO: `#is-not? local` applies to entire patterns but ideally it would accept
; a capture to check as a local. This needs to be suggested upstream. Until this
; is a part of the CLI's highlighter we can't distinguish between function calls
; on modules and accesses of record fields.
(function_call function: (field_access field: (label) @function)) ; Ideally this pattern would be removed,

; Attributes
(attribute
  "@" @attribute
  name: (identifier) @attribute)

(attribute_value (identifier) @constant)

; Type names
(remote_type_identifier) @type
(type_identifier) @type

; Data constructors
(constructor_name) @constructor

; Literals
(string) @string
(escape_sequence) @string.escape
((escape_sequence) @warning
 ; Deprecated in v0.33.0-rc2:
 (#eq? @warning "\\e"))
(bit_array_segment_option) @function.builtin
(integer) @number
(float) @number

; Reserved identifiers
; TODO: when tree-sitter supports `#any-of?` in the Rust bindings,
; refactor this to use `#any-of?` rather than `#match?`
((identifier) @error
 (#any-of? @error "auto" "delegate" "derive" "else" "implement" "macro" "test"))

; Keywords
[
  (visibility_modifier) ; "pub"
  (opacity_modifier) ; "opaque"
  "as"
  "assert"
  "case"
  "const"
  "echo"
  ; DEPRECATED: 'external' was removed in v0.30.
  "external"
  "fn"
  "if"
  "import"
  "let"
  "panic"
  "todo"
  "type"
  "use"
] @keyword

; Operators
(binary_expression
  operator: _ @operator)
(boolean_negation "!" @operator)
(integer_negation "-" @operator)
