; Highlights for Jsonnet, written by hand from tree-sitter-jsonnet's
; queries/highlights.scm (MIT). Upstream paints references to parameters,
; functions and variables with tree-sitter-highlight's `#is? parameter`,
; `#is? function` and `#is? var`, which depend on locals tracking that Rune
; does not do. All six of those patterns are dropped: the four `(id)` ones
; painted every identifier, `std` included, and the two computed field name
; ones (`[id]`) painted every such id as a parameter, then as @define. Ids
; in computed field names stay @field, from the static field name pattern.
; Keep the patterns in upstream's order; only those patterns differ.

(id) @variable
(comment) @comment

; Literals
(null) @constant.builtin
(string) @string
(number) @number
[
  (true)
  (false)
] @boolean

; Keywords
"for" @repeat
"in" @keyword.operator
"function" @keyword.function
[
  "if"
  "then"
  "else"
] @conditional
[
  (local)
  (tailstrict)
  "function"
  "assert"
  "error"
] @keyword

[
  (dollar)
  (self)
  (super)
] @variable.builtin
((id) @variable.builtin
 (#eq? @variable.builtin "std"))

; Operators
[
  (multiplicative)
  (additive)
  (bitshift)
  (comparison)
  (equality)
  (bitand)
  (bitxor)
  (bitor)
  (and)
  (or)
  (unaryop)
] @operator

; Punctuation
[
  "["
  "]"
  "{"
  "}"
  "("
  ")"
] @punctuation.bracket

[
  "."
  ","
  ";"
  ":"
] @punctuation.delimiter

[
  "::"
  ":::"
] @punctuation.special

(field
  (fieldname) "+" @punctuation.special)

; Imports
[
  (import)
  (importstr)
] @include

; References

; Make reference same color as parameter 
; (may incur performance issues on big files)
; Depends on locals.scm
; References do not apply to static field IDs
; Workaround for `(#is-not? local)` not supported
(fieldname (id) @field)
(fieldname (string
             (string_start) @text.strong
             (string_content) @field
             (string_end) @text.strong
           ))

; Functions
(field
  function: (fieldname (id) @function))
(field
  function: (fieldname
              (string
                (string_start) @text.strong
                (string_content) @function
                (string_end) @text.strong
              )))
(param
  identifier: (id) @parameter)

(bind (id) @define)
(bind function: (id) @function)

; Function call
(functioncall
  (fieldaccess
    last: (id) @function.call
  )?
  (fieldaccess_super
    (id) @function.call
  )?
  (id)? @function.call
  "("
  (args
    (named_argument
      (id) @parameter
    )
  )?
  ")"
)

; Emphasize implicit plus usage
(implicit_plus
  (_ "}"? @text.danger)
  (object
    "{" @text.danger
  )
)

; ERROR
(ERROR) @error
