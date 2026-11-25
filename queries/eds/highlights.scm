; Highlights for the EDS grammar, written by hand from nvim-treesitter's
; runtime/queries/eds/highlights.scm (Apache-2.0). Upstream writes its
; case-insensitive regexes with Vim's `\c` flag, which RE2 rejects, so the
; whole query failed to compile; they use RE2's `(?i)` here instead. Its one
; `#lua-match?`, which Rune does not evaluate, is the equivalent `#match?`.
; Keep the patterns in upstream's order; only those predicates differ.

"=" @punctuation.delimiter

[
  "["
  "]"
] @punctuation.bracket

((section_name) @variable.builtin
  (#match? @variable.builtin
    "(?i)^(FileInfo|DeviceInfo|DummyUsage|MandatoryObjects|OptionalObjects)$"))

((section_name) @variable.builtin
  (#match? @variable.builtin "^1"))

(section
  (section_name) @_name
  (#match? @_name "(?i)^Comments$")) @comment

(section
  (section_name) @_name
  (statement
    (key) @_key) @string
  (#match? @_key "(?i)^ParameterName$")
  (#not-match? @_name "(?i)^Comments$"))

(section
  (section_name) @_name
  (statement
    (key) @_key) @type
  (#match? @_key "(?i)^(ObjectType|DataType|AccessType)$")
  (#not-match? @_name "(?i)^Comments$"))

(section
  (section_name) @_name
  (statement
    (key) @_key) @attribute
  (#match? @_key "(?i)^PDOMapping$")
  (#not-match? @_name "(?i)^Comments$"))

(section
  (section_name) @_name
  (statement
    (key) @_key) @number
  (#match? @_key "(?i)^(DefaultValue|LowLimit|HighLimit|SubNumber)$")
  (#not-match? @_name "(?i)^Comments$"))
