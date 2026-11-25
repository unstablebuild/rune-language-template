; inherits: cpp
; Highlights for hlsl, written by hand from nvim-treesitter's
; runtime/queries/hlsl/highlights.scm (Apache-2.0). Upstream matches `SV_`
; system-value semantics with Neovim's `#lua-match?`, which Rune does not
; evaluate: the pattern then painted every identifier as a builtin. That
; predicate is now `#match?` with the same pattern, which reads the same in
; RE2. Keep the patterns in upstream's order; only that predicate differs.

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
