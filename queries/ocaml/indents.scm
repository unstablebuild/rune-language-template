; Indents for OCaml and OCaml interfaces, written by hand from
; nvim-treesitter's runtime/queries/ocaml/indents.scm (Apache-2.0). Upstream
; keeps `else if` out of the else_clause @indent.begin with Neovim's
; `#not-kind-eq?`, which Rune does not evaluate: the pattern then also indented
; every `else if` chain one level deeper per branch. It lists the other
; expression kinds an else_clause can hold instead. Keep the patterns in
; upstream's order; only that pattern differs.

; format-ignore
[ 
  (let_binding)                 ; let = ...
  (type_binding)

  (external)
  (record_declaration)          ; { foo: bar ... }
  (structure)                   ; struct ... end
  (signature)                   ; sig ... end
  (value_specification)         ; val x: bar

  (do_clause)                   ; do ... done
  (match_case)

  (field_expression)
  (application_expression)
  (parenthesized_expression)    ; ( ... )
  (record_expression)           ; { foo = bar ... }
  (list_expression)             ; [...;...]
  (try_expression)              ; try ... with
] @indent.begin

; handle if-else if-else case
(if_expression
  condition: (_) @indent.begin)

(then_clause) @indent.begin

(else_clause
  [
    (application_expression)
    (array_expression)
    (array_get_expression)
    (assert_expression)
    (bigarray_get_expression)
    (boolean)
    (character)
    (coercion_expression)
    (cons_expression)
    (constructor_path)
    (extension)
    (field_get_expression)
    (for_expression)
    (fun_expression)
    (function_expression)
    (hash_expression)
    (infix_expression)
    (lazy_expression)
    (let_exception_expression)
    (let_expression)
    (let_module_expression)
    (let_open_expression)
    (list_expression)
    (local_open_expression)
    (match_expression)
    (method_invocation)
    (new_expression)
    (number)
    (object_copy_expression)
    (object_expression)
    (ocamlyacc_value)
    (package_expression)
    (parenthesized_expression)
    (prefix_expression)
    (quoted_extension)
    (quoted_string)
    (record_expression)
    (set_expression)
    (sign_expression)
    (string)
    (string_get_expression)
    (tag)
    (try_expression)
    (tuple_expression)
    (typed_expression)
    (unit)
    (value_path)
    (while_expression)
  ]) @indent.begin

((parameter) @indent.begin
  (#set! indent.start_at_same_line))

(_
  (ERROR) @indent.begin
  (#set! indent.start_at_same_line))

(ERROR
  "|" @indent.begin
  (#set! indent.start_at_same_line))

(try_expression
  "with" @indent.branch
  [
    (match_case) @indent.dedent
    (match_case
      [
        (parenthesized_expression)
        (list_expression)
      ] @indent.dedent)
  ])

"}" @indent.branch @indent.end

(list_expression
  "]" @indent.branch)

(parenthesized_expression
  ")" @indent.branch)

";;" @indent.end

(do_clause
  "done" @indent.end @indent.branch)

(structure
  "end" @indent.end @indent.branch)

(signature
  "end" @indent.end @indent.branch)

[
  (string)
  (comment)
] @indent.auto
