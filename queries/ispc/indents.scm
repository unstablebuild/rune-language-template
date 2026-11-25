; inherits: c

; Indents for ispc, written by hand from nvim-treesitter's
; runtime/queries/ispc/indents.scm (Apache-2.0). Upstream excludes braced
; foreach bodies with Neovim's `#not-kind-eq? ... "compound_statement"`, which
; Rune does not evaluate: both patterns then also matched braced bodies,
; double-indenting Allman-style braces. They list every non-compound statement
; kind the ispc grammar allows as a foreach body instead. Keep the patterns in
; upstream's order; only those two patterns differ.

(foreach_statement
  body: [
    (attributed_statement)
    (break_statement)
    (case_statement)
    (continue_statement)
    (do_statement)
    (expression_statement)
    (for_statement)
    (foreach_instance_statement)
    (foreach_statement)
    (goto_statement)
    (if_statement)
    (labeled_statement)
    (return_statement)
    (switch_statement)
    (unmasked_statement)
    (while_statement)
  ]) @indent.begin

(foreach_instance_statement
  body: [
    (attributed_statement)
    (break_statement)
    (case_statement)
    (continue_statement)
    (do_statement)
    (expression_statement)
    (for_statement)
    (foreach_instance_statement)
    (foreach_statement)
    (goto_statement)
    (if_statement)
    (labeled_statement)
    (return_statement)
    (switch_statement)
    (unmasked_statement)
    (while_statement)
  ]) @indent.begin
