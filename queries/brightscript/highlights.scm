; Highlights for the BrightScript grammar, written by hand from
; tree-sitter-brightscript's queries/highlights.scm (ISC). Upstream paints an
; `(m)` node, which grammar.js gained after the checked-in src/parser.c was
; last generated, so the parser built here has no such node and the whole
; query failed to compile. It parses `m` as an identifier, so the rule
; matches identifiers spelled `m` instead, as grammar.js's /m/i does.
;
; Two @variable patterns guard an identifier whose parent is a prefix_exp
; with `#not-has-ancestor? prefix_exp`, which Rune does not evaluate and
; which can never hold for them, so they never matched: they are dropped.
; Keep the patterns in upstream's order; only those rules differ.

; Identifiers
(identifier) @variable

; Function declaration
(function_statement
  name: (identifier) @function)

; Sub declaration
(sub_statement
  name: (identifier) @function)

[
  (sub_start)
  (function_start)
  (end_sub)
  (end_function)
] @keyword.function

; Parameters
(parameter
  name: (identifier) @variable.parameter)

; Types
(type_specifier) @type

; Variables
; Properties in variable declarator
(variable_declarator
  (prefix_exp)
  (identifier) @property)

(multiplicative_expression
  operator: (_) @keyword.operator)

(logical_not_expression
  operator: (_) @keyword.operator)

(logical_expression
  operator: (_) @keyword.operator)

; Property access
; All other identifiers in a chain (properties)
(prefix_exp
  (prefix_exp)
  (identifier) @property)

; Function calls
(function_call
  function: (prefix_exp
    (identifier) @function.call))

; Statements
[
  (if_start)
  (else)
  (else_if)
  (end_if)
  (then)
  (conditional_compl_end_if)
] @keyword.conditional

[
  (for_start)
  (while_start)
  (for_each)
  (for_in)
  (for_to)
  (for_step)
  (end_for)
  (end_while)
  (exit_while_statement)
  (exit_for_statement)
] @keyword.repeat

; Statements
[
  (try_start)
  (try_catch)
  (throw)
  (end_try)
] @keyword.exception

(return) @keyword.return

(print) @function.builtin

(constant) @constant

; Operators
[
  "="
  "<>"
  "<"
  "<="
  ">"
  ">="
  "+"
  "-"
  "*"
  "/"
] @operator

; Literals
(boolean) @boolean

(number) @number

(string) @string

(invalid) @constant.builtin

; Comments
(comment) @comment @spell

; Punctuation
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
  "?["
] @punctuation.bracket

[
  "."
  ","
  "?."
] @punctuation.delimiter

; Special highlights for library statements
(library_statement) @keyword.import

(library_statement
  path: (string) @module)

; Array and associative array literals
(array) @constructor

(assoc_array) @constructor

(assoc_array_element
  key: (identifier) @property)

; Increment/decrement operators
[
  (prefix_increment_expression)
  (prefix_decrement_expression)
  (postfix_increment_expression)
  (postfix_decrement_expression)
] @operator

; Comparison operators
(comparison_expression
  [
    "="
    "<>"
    "<"
    "<="
    ">"
    ">="
  ] @operator)

(as) @keyword.operator
((identifier) @keyword
  (#match? @keyword "^[mM]$"))
