; Indents for C and the grammars that inherit it (arduino, cuda, glsl, hlsl,
; ispc, nqc, objc, slang), written by hand from nvim-treesitter's
; runtime/queries/c/indents.scm (Apache-2.0). Upstream excludes braced bodies
; with Neovim's `#not-kind-eq? ... "compound_statement"`, which Rune does not
; evaluate: the for and while patterns then also matched braced bodies,
; double-indenting Allman-style braces, and the unbraced-if pattern matched
; braced consequences holding a bare declaration (`{ struct s; }`), whose ";"
; is a direct child of compound_statement. Those three patterns list the
; non-compound statement kinds instead (for the if pattern, the ones with a
; direct ";" child), limited to the kinds every inheriting grammar has, so the
; query compiles in all of them. Grammar-specific bodies (C++ try/throw/co_*,
; seh_*, for_range_loop, ispc foreach, ...) therefore get nothing from them.
; Keep the patterns in upstream's order; only those three patterns differ.

[
  (compound_statement)
  (field_declaration_list)
  (case_statement)
  (enumerator_list)
  (compound_literal_expression)
  (initializer_list)
  (init_declarator)
] @indent.begin

; With current indent logic, if we capture expression_statement with @indent.begin
; It will be affected by _parent_ node with error subnodes deep down the tree
; So narrow indent capture to check for error inside expression statement only,
(expression_statement
  (_) @indent.begin
  ";" @indent.end)

(ERROR
  "for"
  "(" @indent.begin
  ";"
  ";"
  ")" @indent.end)

(for_statement
  body: [
    (attributed_statement)
    (break_statement)
    (case_statement)
    (continue_statement)
    (do_statement)
    (expression_statement)
    (for_statement)
    (goto_statement)
    (if_statement)
    (labeled_statement)
    (return_statement)
    (switch_statement)
    (while_statement)
  ]) @indent.begin

(while_statement
  condition: (_) @indent.begin)

(while_statement
  body: [
    (attributed_statement)
    (break_statement)
    (case_statement)
    (continue_statement)
    (do_statement)
    (expression_statement)
    (for_statement)
    (goto_statement)
    (if_statement)
    (labeled_statement)
    (return_statement)
    (switch_statement)
    (while_statement)
  ]) @indent.begin

((if_statement)
  .
  (ERROR
    "else" @indent.begin))

(if_statement
  condition: (_) @indent.begin)

; Supports if without braces (but not both if-else without braces)
(if_statement
  consequence: [
    (break_statement
      ";" @indent.end)
    (continue_statement
      ";" @indent.end)
    (do_statement
      ";" @indent.end)
    (expression_statement
      ";" @indent.end)
    (for_statement
      ";" @indent.end)
    (goto_statement
      ";" @indent.end)
    (return_statement
      ";" @indent.end)
  ]
  alternative: (else_clause
    "else" @indent.branch
    [
      (if_statement
        (compound_statement) @indent.dedent)? @indent.dedent
      (compound_statement)? @indent.dedent
      (_)? @indent.dedent
    ])?) @indent.begin

(else_clause
  (_
    .
    "{" @indent.branch))

(compound_statement
  "}" @indent.end)

[
  ")"
  "}"
  (statement_identifier)
] @indent.branch

[
  "#define"
  "#ifdef"
  "#ifndef"
  "#elif"
  "#if"
  "#else"
  "#endif"
] @indent.zero

[
  (preproc_arg)
  (string_literal)
] @indent.ignore

((ERROR
  (parameter_declaration)) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

([
  (argument_list)
  (parameter_list)
] @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

(comment) @indent.auto
