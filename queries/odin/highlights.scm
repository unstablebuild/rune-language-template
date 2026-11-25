; Highlights for Odin, written by hand from tree-sitter-odin's
; queries/highlights.scm (MIT). Upstream uses Neovim's `#lua-match?` and
; `#not-has-parent?`, which Rune does not evaluate, so each pattern would apply
; to every node it structurally matches. The `#lua-match?` predicates are now
; `#match?` with the same patterns in RE2. The capitalized-identifier @type
; and @constant patterns excluded some parents with `#not-has-parent?`; they now
; list the other parents an identifier can have in tree-sitter-odin's
; node-types.json. Keep the patterns in upstream's order; only these
; predicates differ.

; Preprocs

[
  (calling_convention)
  (tag)
] @preproc

; Includes

[
  "import"
  "package"
] @include

; Keywords

[
  "foreign"
  "using"
  "struct"
  "enum"
  "union"
  "defer"
  "cast"
  "transmute"
  "auto_cast"
  "map"
  "bit_set"
  "matrix"
  "bit_field"
] @keyword

[
  "proc"
] @keyword.function

[
  "return"
  "or_return"
] @keyword.return

[
  "distinct"
  "dynamic"
] @storageclass

; Conditionals

[
  "if"
  "else"
  "when"
  "switch"
  "case"
  "where"
  "break"
  (fallthrough_statement)
] @conditional

((ternary_expression
  [
    "?"
    ":"
    "if"
    "else"
    "when"
  ] @conditional.ternary)
  (#set! "priority" 105))

; Repeats

[
  "for"
  "do"
  "continue"
] @repeat

; Variables

(identifier) @variable

; Namespaces

(package_declaration (identifier) @namespace)

(import_declaration alias: (identifier) @namespace)

(foreign_block (identifier) @namespace)

(using_statement (identifier) @namespace)

; Parameters

(parameter (identifier) @parameter ":" "="? (identifier)? @constant)

(default_parameter (identifier) @parameter ":=")

(named_type (identifier) @parameter)

(call_expression argument: (identifier) @parameter "=")

; Functions

(procedure_declaration (identifier) @type)

(procedure_declaration (identifier) @function (procedure (block)))

(procedure_declaration (identifier) @function (procedure (uninitialized)))

(overloaded_procedure_declaration (identifier) @function)

(call_expression function: (identifier) @function.call)

; Types

(type (identifier) @type)

((type (identifier) @type.builtin)
  (#any-of? @type.builtin
    "bool" "byte" "b8" "b16" "b32" "b64"
    "int" "i8" "i16" "i32" "i64" "i128"
    "uint" "u8" "u16" "u32" "u64" "u128" "uintptr"
    "i16le" "i32le" "i64le" "i128le" "u16le" "u32le" "u64le" "u128le"
    "i16be" "i32be" "i64be" "i128be" "u16be" "u32be" "u64be" "u128be"
    "float" "double" "f16" "f32" "f64" "f16le" "f32le" "f64le" "f16be" "f32be" "f64be"
    "complex32" "complex64" "complex128" "complex_float" "complex_double"
    "quaternion64" "quaternion128" "quaternion256"
    "rune" "string" "cstring" "rawptr" "typeid" "any"))

"..." @type.builtin

(struct_declaration (identifier) @type "::")

(enum_declaration (identifier) @type "::")

(union_declaration (identifier) @type "::")

(bit_field_declaration (identifier) @type "::")

(const_declaration (identifier) @type "::" [(array_type) (distinct_type) (bit_set_type) (pointer_type)])

(struct . (identifier) @type)

(field_type . (identifier) @namespace "." (identifier) @type)

(bit_set_type (identifier) @type ";")

(procedure_type (parameters (parameter (identifier) @type)))

(polymorphic_parameters (identifier) @type)

([
  (address (identifier) @type)
  (array_type (identifier) @type)
  (assignment_statement (identifier) @type)
  (attribute (identifier) @type)
  (binary_expression (identifier) @type)
  (bit_field_declaration (identifier) @type)
  (bit_field_type (identifier) @type)
  (bit_set (identifier) @type)
  (bit_set_type (identifier) @type)
  (block (identifier) @type)
  (break_statement (identifier) @type)
  (cast_expression (identifier) @type)
  (conditional_type (identifier) @type)
  (const_declaration (identifier) @type)
  (const_type_declaration (identifier) @type)
  (continue_statement (identifier) @type)
  (default_parameter (identifier) @type)
  (default_type (identifier) @type)
  (defer_statement (identifier) @type)
  (else_clause (identifier) @type)
  (else_if_clause (identifier) @type)
  (else_when_clause (identifier) @type)
  (enum_declaration (identifier) @type)
  (enum_type (identifier) @type)
  (field (identifier) @type)
  (field_identifier (identifier) @type)
  (field_type (identifier) @type)
  (for_statement (identifier) @type)
  (foreign_block (identifier) @type)
  (if_statement (identifier) @type)
  (import_declaration (identifier) @type)
  (in_expression (identifier) @type)
  (index_expression (identifier) @type)
  (label_statement (identifier) @type)
  (map (identifier) @type)
  (matrix (identifier) @type)
  (matrix_type (identifier) @type)
  (member_expression (identifier) @type)
  (named_type (identifier) @type)
  (or_break_expression (identifier) @type)
  (or_continue_expression (identifier) @type)
  (or_return_expression (identifier) @type)
  (overloaded_procedure_declaration (identifier) @type)
  (package_declaration (identifier) @type)
  (parenthesized_expression (identifier) @type)
  (polymorphic_parameters (identifier) @type)
  (range_expression (identifier) @type)
  (return_statement (identifier) @type)
  (selector_call_expression (identifier) @type)
  (slice_expression (identifier) @type)
  (source_file (identifier) @type)
  (struct (identifier) @type)
  (struct_declaration (identifier) @type)
  (struct_field (identifier) @type)
  (struct_member (identifier) @type)
  (switch_case (identifier) @type)
  (switch_statement (identifier) @type)
  (ternary_expression (identifier) @type)
  (type (identifier) @type)
  (unary_expression (identifier) @type)
  (union_declaration (identifier) @type)
  (update_statement (identifier) @type)
  (using_statement (identifier) @type)
  (var_declaration (identifier) @type)
  (variable_declaration (identifier) @type)
  (variadic_expression (identifier) @type)
  (when_statement (identifier) @type)
  (where_clause (identifier) @type)
]
  (#match? @type "^[A-Z][a-zA-Z0-9]*$"))

; Fields

(member_expression "." (identifier) @field)

(struct_type "{" (identifier) @field)

(struct_field (identifier) @field "="?)

(field (identifier) @field)

; Constants

([
  (address (identifier) @constant)
  (array_type (identifier) @constant)
  (assignment_statement (identifier) @constant)
  (attribute (identifier) @constant)
  (binary_expression (identifier) @constant)
  (bit_field_declaration (identifier) @constant)
  (bit_field_type (identifier) @constant)
  (bit_set (identifier) @constant)
  (bit_set_type (identifier) @constant)
  (block (identifier) @constant)
  (break_statement (identifier) @constant)
  (call_expression (identifier) @constant)
  (cast_expression (identifier) @constant)
  (conditional_type (identifier) @constant)
  (const_declaration (identifier) @constant)
  (const_type_declaration (identifier) @constant)
  (continue_statement (identifier) @constant)
  (default_parameter (identifier) @constant)
  (default_type (identifier) @constant)
  (defer_statement (identifier) @constant)
  (else_clause (identifier) @constant)
  (else_if_clause (identifier) @constant)
  (else_when_clause (identifier) @constant)
  (enum_declaration (identifier) @constant)
  (enum_type (identifier) @constant)
  (field (identifier) @constant)
  (field_identifier (identifier) @constant)
  (field_type (identifier) @constant)
  (for_statement (identifier) @constant)
  (foreign_block (identifier) @constant)
  (if_statement (identifier) @constant)
  (import_declaration (identifier) @constant)
  (in_expression (identifier) @constant)
  (index_expression (identifier) @constant)
  (label_statement (identifier) @constant)
  (map (identifier) @constant)
  (matrix (identifier) @constant)
  (matrix_type (identifier) @constant)
  (member_expression (identifier) @constant)
  (named_type (identifier) @constant)
  (or_break_expression (identifier) @constant)
  (or_continue_expression (identifier) @constant)
  (or_return_expression (identifier) @constant)
  (overloaded_procedure_declaration (identifier) @constant)
  (package_declaration (identifier) @constant)
  (parenthesized_expression (identifier) @constant)
  (polymorphic_parameters (identifier) @constant)
  (procedure_declaration (identifier) @constant)
  (range_expression (identifier) @constant)
  (return_statement (identifier) @constant)
  (selector_call_expression (identifier) @constant)
  (slice_expression (identifier) @constant)
  (source_file (identifier) @constant)
  (struct (identifier) @constant)
  (struct_declaration (identifier) @constant)
  (struct_field (identifier) @constant)
  (struct_member (identifier) @constant)
  (switch_case (identifier) @constant)
  (switch_statement (identifier) @constant)
  (ternary_expression (identifier) @constant)
  (unary_expression (identifier) @constant)
  (union_declaration (identifier) @constant)
  (update_statement (identifier) @constant)
  (using_statement (identifier) @constant)
  (var_declaration (identifier) @constant)
  (variable_declaration (identifier) @constant)
  (variadic_expression (identifier) @constant)
  (when_statement (identifier) @constant)
  (where_clause (identifier) @constant)
]
  (#match? @constant "^_*[A-Z][A-Z0-9_]*$"))

(member_expression . "." (identifier) @constant)

(enum_declaration "{" (identifier) @constant)

; Macros

((call_expression function: (identifier) @function.macro)
  (#match? @function.macro "^_*[A-Z][A-Z0-9_]*$"))

; Attributes

(attribute (identifier) @attribute "="?)

; Labels

(label_statement (identifier) @label ":")

; Literals

(number) @number

(float) @float

(string) @string

(character) @character

(escape_sequence) @string.escape

(boolean) @boolean

[
  (uninitialized)
  (nil)
] @constant.builtin

((identifier) @variable.builtin
  (#any-of? @variable.builtin "context" "self"))

; Operators

[
  ":="
  "="
  "+"
  "-"
  "*"
  "/"
  "%"
  "%%"
  ">"
  ">="
  "<"
  "<="
  "=="
  "!="
  "~="
  "|"
  "~"
  "&"
  "&~"
  "<<"
  ">>"
  "||"
  "&&"
  "!"
  "^"
  ".."
  "+="
  "-="
  "*="
  "/="
  "%="
  "&="
  "|="
  "^="
  "<<="
  ">>="
  "||="
  "&&="
  "&~="
  "..="
  "..<"
  "?"
] @operator

[
  "or_else"
  "in"
  "not_in"
] @keyword.operator

; Punctuation

[ "{" "}" ] @punctuation.bracket

[ "(" ")" ] @punctuation.bracket

[ "[" "]" ] @punctuation.bracket

[
  "::"
  "->"
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter


[
  "@"
  "$"
] @punctuation.special

; Comments

[
  (comment)
  (block_comment)
] @comment @spell

; Errors

(ERROR) @error
