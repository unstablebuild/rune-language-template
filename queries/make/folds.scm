; Folds for make, written by hand from nvim-treesitter's
; runtime/queries/make/folds.scm (Apache-2.0). Upstream trims the fold with
; Neovim's `#trim!`, which Rune does not evaluate. The directive is removed
; and the pattern kept, so conditional, rule and define_directive folds also
; cover trailing blank lines. Keep the patterns in upstream's order; only that
; directive differs.

[
  (conditional)
  (rule)
  (define_directive)
] @fold
