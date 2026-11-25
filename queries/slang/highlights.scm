; inherits: c
; Highlights for Slang, written by hand from nvim-treesitter's
; runtime/queries/slang/highlights.scm (Apache-2.0). Upstream uses Neovim's
; `#lua-match?`, `#has-parent?` and `#has-ancestor?`, which Rune does not
; evaluate, so each pattern would apply to every node it structurally matches.
; The `#lua-match?` predicates are now `#match?` with the same patterns in RE2.
; The field_expression @function.method pattern is dropped: its
; `#has-parent?` asks for a template_method or function_declarator parent, and
; tree-sitter-slang's node-types.json allows a field_expression under neither,
; so it never matched. The three patterns for identifiers four or more
; qualified_identifier levels deep are kept without `#has-ancestor?`, whose
; ancestor can be any number of levels up. Their structure already limits them
; to long `a::b::c::d::name` chains, which are rare; such a name outside a call
; now gets @function.call, including in a function declarator, where upstream
; painted @function. Keep the patterns in upstream's order; only these
; predicates and the dropped pattern differ.

; cpp
((identifier) @variable.member
  (#match? @variable.member "^m_.*$"))

(parameter_declaration
  declarator: (reference_declarator) @variable.parameter)

; function(Foo ...foo)
(variadic_parameter_declaration
  declarator: (variadic_declarator
    (_) @variable.parameter))

; int foo = 0
(optional_parameter_declaration
  declarator: (_) @variable.parameter)

;(field_expression) @variable.parameter ;; How to highlight this?
(field_declaration
  (field_identifier) @variable.member)

(field_initializer
  (field_identifier) @property)

(function_declarator
  declarator: (field_identifier) @function.method)

(concept_definition
  name: (identifier) @type.definition)

(alias_declaration
  name: (type_identifier) @type.definition)

(namespace_identifier) @module

((namespace_identifier) @type
  (#match? @type "^[A-Z]"))

(case_statement
  value: (qualified_identifier
    (identifier) @constant))

(using_declaration
  .
  "using"
  .
  "namespace"
  .
  [
    (qualified_identifier)
    (identifier)
  ] @module)

(destructor_name
  (identifier) @function.method)

; functions
(function_declarator
  (qualified_identifier
    (identifier) @function))

(function_declarator
  (qualified_identifier
    (qualified_identifier
      (identifier) @function)))

(function_declarator
  (qualified_identifier
    (qualified_identifier
      (qualified_identifier
        (identifier) @function))))

((qualified_identifier
  (qualified_identifier
    (qualified_identifier
      (qualified_identifier
        (identifier) @function)))))

(function_declarator
  (template_function
    (identifier) @function))

(operator_name) @function

"operator" @function

"static_assert" @function.builtin

(call_expression
  (qualified_identifier
    (identifier) @function.call))

(call_expression
  (qualified_identifier
    (qualified_identifier
      (identifier) @function.call)))

(call_expression
  (qualified_identifier
    (qualified_identifier
      (qualified_identifier
        (identifier) @function.call))))

((qualified_identifier
  (qualified_identifier
    (qualified_identifier
      (qualified_identifier
        (identifier) @function.call)))))

(call_expression
  (template_function
    (identifier) @function.call))

(call_expression
  (qualified_identifier
    (template_function
      (identifier) @function.call)))

(call_expression
  (qualified_identifier
    (qualified_identifier
      (template_function
        (identifier) @function.call))))

(call_expression
  (qualified_identifier
    (qualified_identifier
      (qualified_identifier
        (template_function
          (identifier) @function.call)))))

((qualified_identifier
  (qualified_identifier
    (qualified_identifier
      (qualified_identifier
        (template_function
          (identifier) @function.call))))))

; methods
(function_declarator
  (template_method
    (field_identifier) @function.method))

(call_expression
  (field_expression
    (field_identifier) @function.method.call))

; constructors
((function_declarator
  (qualified_identifier
    (identifier) @constructor))
  (#match? @constructor "^[A-Z]"))

((call_expression
  function: (identifier) @constructor)
  (#match? @constructor "^[A-Z]"))

((call_expression
  function: (qualified_identifier
    name: (identifier) @constructor))
  (#match? @constructor "^[A-Z]"))

((call_expression
  function: (field_expression
    field: (field_identifier) @constructor))
  (#match? @constructor "^[A-Z]"))

; constructing a type in an initializer list: Constructor ():  **SuperType (1)**
((field_initializer
  (field_identifier) @constructor
  (argument_list))
  (#match? @constructor "^[A-Z]"))

; Constants
(this) @variable.builtin

(null
  "nullptr" @constant.builtin)

(true) @boolean

(false) @boolean

; Literals
(raw_string_literal) @string

; Keywords
[
  "try"
  "catch"
  "noexcept"
  "throw"
] @keyword.exception

[
  "decltype"
  "explicit"
  "friend"
  "override"
  "using"
  "requires"
  "constexpr"
] @keyword

[
  "class"
  "namespace"
  "template"
  "typename"
  "concept"
] @keyword.type

[
  "co_await"
  "co_yield"
  "co_return"
] @keyword.coroutine

[
  "public"
  "private"
  "protected"
  "final"
  "virtual"
] @keyword.modifier

[
  "new"
  "delete"
  "xor"
  "bitand"
  "bitor"
  "compl"
  "not"
  "xor_eq"
  "and_eq"
  "or_eq"
  "not_eq"
  "and"
  "or"
] @keyword.operator

"<=>" @operator

"::" @punctuation.delimiter

(template_argument_list
  [
    "<"
    ">"
  ] @punctuation.bracket)

(template_parameter_list
  [
    "<"
    ">"
  ] @punctuation.bracket)

(literal_suffix) @operator

; hlsl
[
  "in"
  "out"
  "inout"
  "uniform"
  "shared"
  "groupshared"
  "discard"
  "cbuffer"
  "row_major"
  "column_major"
  "globallycoherent"
  "centroid"
  "noperspective"
  "nointerpolation"
  "sample"
  "linear"
  "snorm"
  "unorm"
  "point"
  "line"
  "triangleadj"
  "lineadj"
  "triangle"
] @keyword.modifier

((identifier) @variable.builtin
  (#match? @variable.builtin "^SV_"))

(hlsl_attribute) @attribute

(hlsl_attribute
  [
    "["
    "]"
  ] @attribute)

[
  "var"
  "let"
  "This"
] @type.builtin

[
  "interface"
  "extension"
  "property"
  "associatedtype"
  "where"
] @keyword

"__init" @constructor

[
  "__subscript"
  "get"
  "set"
] @function.builtin

(interface_requirements
  (identifier) @type)

(binary_expression
  [
    "is"
    "as"
  ]
  right: (identifier) @type)

[
  "as"
  "is"
] @keyword.operator

[
  "__exported"
  "import"
] @keyword.import

(property_declaration
  (identifier) @property)
