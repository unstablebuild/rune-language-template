; Highlights for linkerscript, written by hand from
; tree-sitter-linkerscript/queries/highlights.scm (MIT). Upstream matches with
; Neovim's `#lua-match?`, which Rune does not evaluate: each such pattern then
; painted every node it structurally matched. The 2 predicates now use `#match?`
; with the Lua patterns translated to RE2, matching the same text. Keep the
; patterns in upstream's order; only those predicates differ.

; Keywords

[
  "ENTRY"
  "SECTIONS"
  "AT"
  "OVERLAY"
  "NOCROSSREFS"
  "MEMORY"
  "PHDRS"
  "FILEHDR"
] @keyword

; Conditionals

(conditional_expression [ "?" ":" ] @conditional.ternary)

; Variables

(symbol) @variable

(filename) @string.special @text.underline

; Functions

(call_expression
  function: (symbol) @function.call)

((call_expression
  function: (symbol) @preproc)
  (#eq? @preproc "DEFINED"))

((call_expression
  function: (symbol) @function.builtin)
  (#any-of? @function.builtin
   "ABSOLUTE" "ALIAS" "ADDR" "ALIGN" "ALIGNOF" "BASE" "BLOCK" "CHIP" "DATA_SEGMENT_ALIGN"
   "DATA_SEGMENT_END" "DATA_SEGMENT_RELRO_END" "END" "LENGTH" "LOADADDR" "LOG2CEIL" "MAX" "MIN"
   "NEXT" "ORIGIN" "SEGMENT_START" "SIZEOF" "BYTE" "FILL" "LONG" "SHORT" "QUAD" "SQUAD" "WORD"))

[
  "KEEP"
  "PROVIDE"
  "PROVIDE_HIDDEN"
] @function.builtin

; Types

(section_type "(" [ "NOLOAD" "DSECT" "COPY" "INFO" "OVERLAY" ] @type.builtin ")")

; Fields

[
  "ORIGIN" "org" "o"
  "LENGTH" "len" "l"
] @field.builtin

; Constants

((symbol) @constant
  (#match? @constant "^[A-Z_][A-Z0-9_]+$"))

; Labels

(entry_command name: (symbol) @label)

(output_section name: (symbol) @label)

(memory_command name: (symbol) @label)

(phdrs_command name: (symbol) @label)

(region ">" (symbol) @label)

(lma_region ">" (symbol) @label)

(phdr ":" (symbol) @label)

([(symbol) (filename)] @label
  (#match? @label "^\\."))

; Exceptions

"ASSERT" @exception

[
  "/DISCARD/"
  "."
] @variable.builtin

; Operators

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "||"
  "&&"
  "|"
  "&"
  "=="
  "!="
  ">"
  ">="
  "<="
  "<"
  "<<"
  ">>"
  "!"
  "~"
  "="
  "+="
  "-="
  "*="
  "/="
  "<<="
  ">>="
  "&="
  "|="
] @operator

; Literals

(number) @number

(quoted_symbol) @string

(wildcard_pattern [ "*" "[" "]" ] @character.special)

(attributes) @character.special

; Punctuation

[ "{" "}" "(" ")" ] @punctuation.bracket

[
  ":"
  ";"
] @punctuation.delimiter

">" @punctuation.special

; Comments

(comment) @comment @spell
