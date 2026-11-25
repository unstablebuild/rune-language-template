; Folds for markdown, written by hand from nvim-treesitter's
; runtime/queries/markdown/folds.scm (Apache-2.0). Upstream trims both folds
; with Neovim's `#trim!`, which Rune does not evaluate. The directive is
; removed from both patterns and the patterns kept, so code block, list item,
; section and list folds also cover trailing blank lines. Keep the patterns in
; upstream's order; only that directive differs.

[
  (fenced_code_block)
  (indented_code_block)
  (list_item
    (list))
  (section)
] @fold

(section
  (list) @fold)
