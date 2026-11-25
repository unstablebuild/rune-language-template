; Highlights for the C++ grammar, written by hand from tree-sitter-cpp's
; queries/highlights.scm (MIT). C++ is not built here; this file is what cuda,
; arduino and hlsl inherit. tree-sitter-cuda and tree-sitter-arduino are built
; on an older tree-sitter-cpp without C++20 modules, so the `module_name`
; pattern and the "import", "export" and "module" keywords name nodes their
; grammars lack, and the whole query failed to compile. Both are removed;
; HLSL has no modules either. Keep the patterns in upstream's order; only the
; module rules differ.

; Functions

(call_expression
  function: (qualified_identifier
    name: (identifier) @function))

(template_function
  name: (identifier) @function)

(template_method
  name: (field_identifier) @function)

(template_function
  name: (identifier) @function)

(function_declarator
  declarator: (qualified_identifier
    name: (identifier) @function))

(function_declarator
  declarator: (field_identifier) @function)

; Types

((namespace_identifier) @type
 (#match? @type "^[A-Z]"))

(auto) @type

; Constants

(this) @variable.builtin
(null "nullptr" @constant)

; Keywords

[
 "catch"
 "class"
 "co_await"
 "co_return"
 "co_yield"
 "constexpr"
 "constinit"
 "consteval"
 "delete"
 "explicit"
 "final"
 "friend"
 "mutable"
 "namespace"
 "noexcept"
 "new"
 "override"
 "private"
 "protected"
 "public"
 "template"
 "throw"
 "try"
 "typename"
 "using"
 "concept"
 "requires"
 "virtual"
] @keyword

; Strings

(raw_string_literal) @string
