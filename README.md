# rune-language-template
This repository can be used to create new language packages as-is, or be cloned to extend
the default queries or tools installed for a language.

To create a new language package simply update the variable LANG at the top of the Makefile
and run `make` to generate a tar, and `make dist` to publish it to the configured package
manager

## Why clone the repo

### Standard tooling
We should strive to keep the tools of the languages that we support insulated from the environment,
so it's a good practice to create a $(LANG) folder and compile a language's standard tools
and provide them in the form of executables.

### Initial folds override of folds.scm
You can add a folds.scm file in the src folder to extend the default folds.scm and
enable the initial folds feature in Rune:

```scm
[
  (const_declaration)
  (for_statement)
  (func_literal)
  (function_declaration)
  (if_statement)
  (import_declaration)
  (method_declaration)
  (type_declaration)
  (var_declaration)
  (composite_literal)
  (literal_element)
  (block)
] @fold

[
  (import_declaration)
] @initial_fold
```
