; Highlights for thrift, written by hand from
; tree-sitter-thrift/queries/highlights.scm (MIT). Upstream matches with
; Neovim's `#lua-match?`, which Rune does not evaluate: each such pattern then
; painted every node it structurally matched. The 6 predicates now use `#match?`
; with the Lua patterns translated to RE2, matching the same text. The block
; doc-comment regex gains (?s) because Lua's "." also matches newlines, so
; upstream's pattern covers multi-line /** ... */ comments. Keep the patterns in
; upstream's order; only those predicates differ.

; Variables

((identifier) @variable
  (#set! "priority" 95))

; Includes

[
  "include"
  "cpp_include"
] @include

; Function

(function_definition
  (identifier) @function)

; Fields

(field (identifier) @field)

; Parameters

(function_definition
  (parameters
    (parameter (identifier) @parameter)))

(throws
  (parameters
    (parameter (identifier) @parameter.exception)))

; Types

(typedef_identifier) @type
(struct_definition
  "struct" (identifier) @type)

(union_definition
  "union" (identifier) @type)

(exception_definition
  "exception" (identifier) @type)

(service_definition
  "service" (identifier) @type)

(interaction_definition
  "interaction" (identifier) @type)

(type
  type: (identifier) @type)

(definition_type
  type: (identifier) @type)

((identifier) @type
  (#match? @type "^[_]*[A-Z]"))

; Constants

(const_definition (identifier) @constant)
((identifier) @constant
  (#match? @constant "^[_A-Z][A-Z0-9_]*$"))
(enum_definition "enum"
  . (identifier) @type
  "{" (identifier) @constant "}")

; Builtin Types

(primitive) @type.builtin

[
  "list"
  "map"
  "set"
  "sink"
  "stream"
  "void"
] @type.builtin

; Namespace

(namespace_declaration
  (namespace_scope) @tag
  [(namespace) @namespace (_ (identifier) @namespace)])

; Attributes

(annotation_definition
  (annotation_identifier (identifier) @attribute))
(fb_annotation_definition
  "@" @attribute (annotation_identifier (identifier) @attribute)
  (identifier)? @attribute)
(namespace_uri (string) @attribute)

; Operators

[
  "="
  "&"
] @operator

; Exceptions

[
  "throws"
] @exception

; Keywords

[
  "enum"
  "exception"
  "extends"
  "interaction"
  "namespace"
  "senum"
  "service"
  "struct"
  "typedef"
  "union"
  "uri"
] @keyword

; Deprecated Keywords

[
  "cocoa_prefix"
  "cpp_namespace"
  "csharp_namespace"
  "delphi_namespace"
  "java_package"
  "perl_package"
  "php_namespace"
  "py_module"
  "ruby_namespace"
  "smalltalk_category"
  "smalltalk_prefix"
  "xsd_all"
  "xsd_attrs"
  "xsd_namespace"
  "xsd_nillable"
  "xsd_optional"
] @keyword

; Extended Kewords
[
  "package"
  "performs"
] @keyword

[
  "async"
  "oneway"
] @keyword.coroutine

; Qualifiers

[
  "client"
  "const"
  "idempotent"
  "optional"
  "permanent"
  "readonly"
  "required"
  "safe"
  "server"
  "stateful"
  "transient"
] @type.qualifier

; Literals

(string) @string

(escape_sequence) @string.escape

(namespace_uri
  (string) @text.uri @string.special)

(number) @number

(double) @float

(boolean) @boolean

; Typedefs

(typedef_identifier) @type.definition

; Punctuation

[
  "*"
] @punctuation.special

["{" "}"] @punctuation.bracket

["(" ")"] @punctuation.bracket

["[" "]"] @punctuation.bracket

["<" ">"] @punctuation.bracket

[
  "."
  ","
  ";"
  ":"
] @punctuation.delimiter

; Comments

(comment) @comment @spell

((comment) @comment.documentation
  (#match? @comment.documentation "(?s)^/[*][*][^*].*[*]/$"))

((comment) @comment.documentation
  (#match? @comment.documentation "^///[^/]"))
((comment) @comment.documentation
  (#match? @comment.documentation "^///$"))

((comment) @preproc
  (#match? @preproc "#!.*"))

; Errors

(ERROR) @error
