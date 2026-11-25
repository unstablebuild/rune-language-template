; Highlights for kconfig, written by hand from
; tree-sitter-kconfig/queries/highlights.scm (MIT). Upstream matches with
; Neovim's `#lua-match?`, which Rune does not evaluate: each such pattern then
; painted every node it structurally matched. The predicate now uses `#match?`
; with the Lua pattern translated to RE2, matching the same text. Keep the
; patterns in upstream's order; only that predicate differs.

[
  "source"
  "osource"
  "rsource"
  "orsource"
] @include

[
  "mainmenu"
  "config"
  "configdefault"
  "menuconfig"
  "choice"
  "endchoice"
  "comment"
  "menu"
  "endmenu"
  "prompt"
  "default"
  "range"
  "help"
  (optional)
  (modules)
] @keyword

[
  "if"
  "endif"
  "depends on"
  "select"
  "imply"
  "visible if"
] @conditional

[
  "def_bool"
  "def_tristate"
] @keyword.function

[
  "||"
  "&&"
  "="
  "!="
  "<"
  ">"
  "<="
  ">="
  "!"
] @operator

[
  "bool"
  "tristate"
  "int"
  "hex"
  "string"
] @type.builtin

[ "(" ")" ] @punctuation.bracket

(macro_variable ["$(" ")"] @punctuation.special)

(symbol) @variable

[
  (string)
  (macro_content)
  (text)
] @string

(config name: (name (symbol) @constant))
(configdefault name: (name (symbol) @constant))
(menuconfig name: (name (symbol) @constant))
(choice name: (name (symbol) @constant))

((symbol) @constant
  (#match? @constant "[A-Z0-9]+"))

(mainmenu name: (string) @text.title)
(comment_entry name: (string) @text.title)
(menu name: (string) @text.title)

(source (string) @text.uri @string.special)

(comment) @comment

(ERROR) @error
