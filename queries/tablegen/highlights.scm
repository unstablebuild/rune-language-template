; Highlights for tablegen, written by hand from
; tree-sitter-tablegen/queries/highlights.scm (MIT). Upstream matches with
; Neovim's `#lua-match?`, which Rune does not evaluate: each such pattern then
; painted every node it structurally matched. The 2 predicates now use `#match?`
; with the Lua patterns translated to RE2, matching the same text. Keep the
; patterns in upstream's order; only those predicates differ.

; Preprocs

(preprocessor_directive) @preproc

; Includes

"include" @include

; Keywords

[
  "assert"
  "class"
  "multiclass"
  "field"
  "let"
  "def"
  "defm"
  "defset"
  "defvar"
] @keyword

[
  "in"
] @keyword.operator

; Conditionals

[
  "if"
  "else"
  "then"
] @conditional

; Repeats

[
  "foreach"
] @repeat

; Variables

(identifier) @variable

(var) @tag ; need something more suitable, but nothing fits as "correctly" as @tag, maybe @variable.builtin

; Parameters

(template_arg (identifier) @parameter)


; Types

(type) @type

[
  "bit"
  "int"
  "string"
  "dag"
  "bits"
  "list"
  "code"
] @type.builtin

(class name: (identifier) @type)

(multiclass name: (identifier) @type)

(def name: (value (_) @type))

(defm name: (value (_) @type))

(defset name: (identifier) @type)

(parent_class_list (identifier) @type (value (_) @type)?)

(anonymous_record (identifier) @type)

(anonymous_record (value (_) @type))

((identifier) @type
  (#match? @type "^_*[A-Z][A-Z0-9_]+$"))

; Fields

(instruction
  (identifier) @field)

(let_instruction
  (identifier) @field)

; Functions

([
  (bang_operator)
  (cond_operator)
] @function
  (#set! "priority" 105))

; Operators

[
  "="
  "#"
  "-"
  ":"
  "..."
] @operator

; Literals

(string) @string

(code) @string.special

(integer) @number

(boolean) @boolean

(uninitialized_value) @constant.builtin

; Punctuation

[ "{" "}" ] @punctuation.bracket

[ "[" "]" ] @punctuation.bracket

[ "(" ")" ] @punctuation.bracket

[ "<" ">" ] @punctuation.bracket

[
  "."
  ","
  ";"
] @punctuation.delimiter

[
 "!"
] @punctuation.special

; Comments

[
  (comment)
  (multiline_comment)
] @comment @spell


((comment) @preproc
  (#match? @preproc "^.*RUN"))

; Errors

(ERROR) @error
