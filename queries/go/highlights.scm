; Highlights for Go, written by hand from nvim-treesitter's
; runtime/queries/go/highlights.scm (Apache-2.0); in this repository only templ
; inherits it. Upstream uses Neovim's `#lua-match?` and `#not-has-parent?`,
; which Rune does not evaluate, so each pattern would apply to every node it
; structurally matches. The two constructor `#lua-match?` predicates are now
; `#match?` with the same patterns in RE2. The @spell string pattern excluded
; import paths with `#not-has-parent? import_spec`; it now lists the other
; parents an interpreted_string_literal can have in tree-sitter-templ's
; node-types.json. Some of them are templ nodes, so a Go package inheriting
; this file would need that list trimmed to Go's node types. Keep the patterns
; in upstream's order; only these predicates differ.
; Forked from tree-sitter-go
; Copyright (c) 2014 Max Brunsfeld (The MIT License)
;
; Identifiers
(type_identifier) @type

(type_spec
  name: (type_identifier) @type.definition)

(field_identifier) @property

(identifier) @variable

(package_identifier) @module

(parameter_declaration
  (identifier) @variable.parameter)

(variadic_parameter_declaration
  (identifier) @variable.parameter)

(label_name) @label

(const_spec
  name: (identifier) @constant)

; Function calls
(call_expression
  function: (identifier) @function.call)

(call_expression
  function: (selector_expression
    field: (field_identifier) @function.method.call))

; Function definitions
(function_declaration
  name: (identifier) @function)

(method_declaration
  name: (field_identifier) @function.method)

(method_elem
  name: (field_identifier) @function.method)

; Constructors
((call_expression
  (identifier) @constructor)
  (#match? @constructor "^[nN]ew.+$"))

((call_expression
  (identifier) @constructor)
  (#match? @constructor "^[mM]ake.+$"))

; Operators
[
  "--"
  "-"
  "-="
  ":="
  "!"
  "!="
  "..."
  "*"
  "*="
  "/"
  "/="
  "&"
  "&&"
  "&="
  "&^"
  "&^="
  "%"
  "%="
  "^"
  "^="
  "+"
  "++"
  "+="
  "<-"
  "<"
  "<<"
  "<<="
  "<="
  "="
  "=="
  ">"
  ">="
  ">>"
  ">>="
  "|"
  "|="
  "||"
  "~"
] @operator

; Keywords
[
  "break"
  "const"
  "continue"
  "default"
  "defer"
  "goto"
  "range"
  "select"
  "var"
  "fallthrough"
] @keyword

[
  "type"
  "struct"
  "interface"
] @keyword.type

"func" @keyword.function

"return" @keyword.return

"go" @keyword.coroutine

"for" @keyword.repeat

[
  "import"
  "package"
] @keyword.import

[
  "else"
  "case"
  "switch"
  "if"
] @keyword.conditional

; Builtin types
[
  "chan"
  "map"
] @type.builtin

((type_identifier) @type.builtin
  (#any-of? @type.builtin
    "any" "bool" "byte" "comparable" "complex128" "complex64" "error" "float32" "float64" "int"
    "int16" "int32" "int64" "int8" "rune" "string" "uint" "uint16" "uint32" "uint64" "uint8"
    "uintptr"))

; Builtin functions
((identifier) @function.builtin
  (#any-of? @function.builtin
    "append" "cap" "clear" "close" "complex" "copy" "delete" "imag" "len" "make" "max" "min" "new"
    "panic" "print" "println" "real" "recover"))

; Delimiters
"." @punctuation.delimiter

"," @punctuation.delimiter

":" @punctuation.delimiter

";" @punctuation.delimiter

"(" @punctuation.bracket

")" @punctuation.bracket

"{" @punctuation.bracket

"}" @punctuation.bracket

"[" @punctuation.bracket

"]" @punctuation.bracket

; Literals
(interpreted_string_literal) @string

(raw_string_literal) @string

(rune_literal) @string

(escape_sequence) @string.escape

(int_literal) @number

(float_literal) @number.float

(imaginary_literal) @number

[
  (true)
  (false)
] @boolean

[
  (nil)
  (iota)
] @constant.builtin

(keyed_element
  .
  (literal_element
    (identifier) @variable.member))

(field_declaration
  name: (field_identifier) @variable.member)

; Comments
(comment) @comment @spell

; Doc Comments
(source_file
  .
  (comment)+ @comment.documentation)

(source_file
  (comment)+ @comment.documentation
  .
  (const_declaration))

(source_file
  (comment)+ @comment.documentation
  .
  (function_declaration))

(source_file
  (comment)+ @comment.documentation
  .
  (type_declaration))

(source_file
  (comment)+ @comment.documentation
  .
  (var_declaration))

; Spell
[
  (argument_list
    (interpreted_string_literal) @spell)
  (array_type
    (interpreted_string_literal) @spell)
  (binary_expression
    (interpreted_string_literal) @spell)
  (call_expression
    (interpreted_string_literal) @spell)
  (component_for_statement
    (interpreted_string_literal) @spell)
  (component_if_statement
    (interpreted_string_literal) @spell)
  (component_render
    (interpreted_string_literal) @spell)
  (component_switch_statement
    (interpreted_string_literal) @spell)
  (conditional_attribute_if_statement
    (interpreted_string_literal) @spell)
  (dec_statement
    (interpreted_string_literal) @spell)
  (defer_statement
    (interpreted_string_literal) @spell)
  (dynamic_class_attribute_value
    (interpreted_string_literal) @spell)
  (expression
    (interpreted_string_literal) @spell)
  (expression_list
    (interpreted_string_literal) @spell)
  (expression_statement
    (interpreted_string_literal) @spell)
  (expression_switch_statement
    (interpreted_string_literal) @spell)
  (field_declaration
    (interpreted_string_literal) @spell)
  (for_clause
    (interpreted_string_literal) @spell)
  (for_statement
    (interpreted_string_literal) @spell)
  (go_statement
    (interpreted_string_literal) @spell)
  (if_statement
    (interpreted_string_literal) @spell)
  (inc_statement
    (interpreted_string_literal) @spell)
  (index_expression
    (interpreted_string_literal) @spell)
  (literal_element
    (interpreted_string_literal) @spell)
  (parenthesized_expression
    (interpreted_string_literal) @spell)
  (range_clause
    (interpreted_string_literal) @spell)
  (receive_statement
    (interpreted_string_literal) @spell)
  (selector_expression
    (interpreted_string_literal) @spell)
  (send_statement
    (interpreted_string_literal) @spell)
  (slice_expression
    (interpreted_string_literal) @spell)
  (spread_attributes
    (interpreted_string_literal) @spell)
  (type_assertion_expression
    (interpreted_string_literal) @spell)
  (type_conversion_expression
    (interpreted_string_literal) @spell)
  (type_switch_statement
    (interpreted_string_literal) @spell)
  (unary_expression
    (interpreted_string_literal) @spell)
  (variadic_argument
    (interpreted_string_literal) @spell)
]

; Regex
(call_expression
  (selector_expression) @_function
  (#any-of? @_function
    "regexp.Match" "regexp.MatchReader" "regexp.MatchString" "regexp.Compile" "regexp.CompilePOSIX"
    "regexp.MustCompile" "regexp.MustCompilePOSIX")
  (argument_list
    .
    [
      (raw_string_literal
        (raw_string_literal_content) @string.regexp)
      (interpreted_string_literal
        (interpreted_string_literal_content) @string.regexp)
    ]))
