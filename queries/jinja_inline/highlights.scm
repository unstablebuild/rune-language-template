; Highlights for the jinja_inline grammar, written by hand from
; tree-sitter-jinja's tree-sitter-jinja_inline/queries/highlights.scm
; (Apache-2.0). It also replaces nvim-treesitter's jinja_inline queries, which
; the jinja package inherits. Upstream's filter rule looks for a "|" token
; inside binary_operator, but binary_operator is a leaf whose text is the
; operator, so the pattern is impossible. Instead of reporting that, tree-sitter
; 0.25 fails an assertion while analyzing the query and aborts the process,
; which took Rune down whenever a Jinja template injected this language. The
; rule tests the operator's text with `#eq?` instead. Keep the patterns in
; upstream's order; only that rule differs.

"#" @keyword.directive

(string_literal) @string

(number_literal) @number

(float_literal) @number.float

(boolean_literal) @boolean

(null_literal) @constant

"defined" @constant

(comment) @comment @spell

[
  ","
  "."
  ":"
] @punctuation.delimiter

[
  (attribute_ignore)
  (attribute_context)
  "recursive"
] @attribute.builtin

[
  "("
  ")"
  "["
  "]"
  "<"
  ">"
] @punctuation.bracket

(binary_operator) @operator

[
  "block"
  "with"
  "filter"
  "macro"
  "set"
  "trans"
  "pluralize"
  "autoescape"
] @keyword

[
  "endtrans"
  "endblock"
  "endwith"
  "endfilter"
  "endmacro"
  "endcall"
  "endset"
  "endtrans"
  "endautoescape"
  "required"
] @keyword

(do_statement
  "do" @keyword)

[
  "include"
  "import"
  "from"
  "extends"
  "as"
] @keyword.import

(identifier) @variable

[
  "if"
  "else"
  "endif"
  "elif"
] @keyword.conditional

[
  "for"
  "in"
  "continue"
  "break"
  "endfor"
] @keyword.repeat

"call" @function.call

(function_call
  (identifier) @function.call)

(arg
  (identifier) @variable.parameter)

(arg
  (expression
    (binary_expression
      (unary_expression
        (primary_expression
          (identifier) @variable.parameter)))))

(expression
  "."
  (expression
    (binary_expression
      .
      (unary_expression
        (primary_expression
          (identifier) @variable.member)))))

(expression
  "."
  (expression
    (binary_expression
      (binary_expression
        (unary_expression
          (primary_expression
            (identifier) @variable.member))))))

(assignment_expression
  "."
  (identifier)+ @variable.member)

; jinja filters
(binary_expression
  (binary_operator) @_op
  (unary_expression
    (primary_expression
      (identifier) @function.call))
  (#eq? @_op "|"))

(inline_trans
  "_" @function.builtin)

"debug" @function.builtin

(raw_end) @keyword

(raw_body) @markup.raw.block @nospell

(builtin_test
  [
    "boolean"
    "even"
    "in"
    "mapping"
    "sequence"
    "callable"
    "integer"
    "ne"
    "string"
    "defined"
    "filter"
    "iterable"
    "none"
    "test"
    "divisibleby"
    "float"
    "le"
    "number"
    "eq"
    "ge"
    "lower"
    "odd"
    "undefined"
    "escaped"
    "gt"
    "lt"
    "sameas"
    "upper"
  ] @keyword.operator)
