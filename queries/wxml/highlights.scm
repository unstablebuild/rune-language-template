; Highlights for WXML, written by hand from nvim-treesitter's
; runtime/queries/wxml/highlights.scm (Apache-2.0). Upstream uses Neovim's
; `#lua-match?` and `#offset!`, which Rune does not evaluate in highlights, so
; each pattern would apply to every node it structurally matches. The
; `#lua-match?` predicates are now `#match?` with the patterns in RE2. In Lua,
; the `-` of upstream's "^data-" is a lazy quantifier on the `a`, so it matched
; every name starting with "dat"; the RE2 "^data-" matches the `data-`
; attributes it was written for. The href/src @string.special.url pattern is
; kept without `#offset!`, so the quotes around the URL are painted with it.
; Keep the patterns in upstream's order; only these predicates differ.

; Comments
(comment) @comment @spell

; Text
(text) @spell

; Tag names
(tag_name) @tag

((tag_name) @tag.builtin
  (#any-of? @tag.builtin "wxs" "template" "import" "include" "slot" "block"))

; Attributes
(attribute_name) @tag.attribute

(attribute_value) @string

(quoted_attribute_value) @string

; WeChat specific attributes
((attribute_name) @keyword.directive
  (#match? @keyword.directive "^wx:"))

((attribute_name) @keyword.conditional
  (#any-of? @keyword.conditional "wx:if" "wx:elif" "wx:else"))

((attribute_name) @keyword.repeat
  (#any-of? @keyword.repeat "wx:for" "wx:for-index" "wx:for-item"))

((attribute_name) @keyword
  (#match? @keyword "^bind"))

((attribute_name) @keyword
  (#match? @keyword "^catch"))

((attribute_name) @keyword
  (#match? @keyword "^mut-bind"))

((attribute_name) @keyword
  (#match? @keyword "^model:"))

((attribute_name) @keyword
  (#match? @keyword "^data-"))

((attribute
  (attribute_name) @_attr
  (quoted_attribute_value) @string.special.url)
  (#any-of? @_attr "href" "src"))

; Entity references
(entity) @character.special

; Interpolation delimiters
(interpolation_start) @punctuation.special

(interpolation_end) @punctuation.special

[
  "<"
  ">"
  "</"
  "/>"
] @tag.delimiter

"=" @operator
