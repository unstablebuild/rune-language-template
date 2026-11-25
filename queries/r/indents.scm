; Indents for R, written by hand from nvim-treesitter's
; runtime/queries/r/indents.scm (Apache-2.0). Upstream keeps `f <- function(x)`
; out of the binary_operator @indent.begin with Neovim's `#not-kind-eq?`, which
; Rune does not evaluate: the pattern then also indented the body of every
; function assigned with `<-` or `=` once more. It lists the other kinds the
; right-hand side can be instead. Keep the patterns in upstream's order; only
; that pattern differs.

[
  (braced_expression)
  (parenthesized_expression)
  (call)
  "if"
  "else"
  "while"
  "repeat"
  "for"
] @indent.begin

(binary_operator
  rhs: [
    (binary_operator)
    (braced_expression)
    (break)
    (call)
    (complex)
    (dot_dot_i)
    (dots)
    (extract_operator)
    (false)
    (float)
    (for_statement)
    (identifier)
    (if_statement)
    (inf)
    (integer)
    (na)
    (namespace_operator)
    (nan)
    (next)
    (null)
    (parenthesized_expression)
    (repeat_statement)
    (return)
    (string)
    (subset)
    (subset2)
    (true)
    (unary_operator)
    (while_statement)
  ]) @indent.begin

[
  "}"
  ")"
] @indent.branch

((parameters
  .
  (parameter
    name: (identifier))) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

[
  ")"
  "}"
] @indent.end

(comment) @indent.ignore
