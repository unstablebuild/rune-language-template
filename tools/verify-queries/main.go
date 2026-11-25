// Command verify-queries checks that the queries of a built language
// package load in Rune.
//
// Usage:
//
//	verify-queries <lib-dir> <lang>
//
// Every <lib-dir>/*.scm must compile against <lib-dir>/tree-sitter.so,
// loaded the way Rune loads it and with the go-tree-sitter build Rune
// links (go.mod pins the same version). A query that fails to compile
// turns that feature of the language off in Rune, and one that trips an
// assertion in tree-sitter takes Rune down with it.
//
// The queries Rune loads must also use only predicates Rune evaluates.
// Rune ignores any other predicate, so its pattern matches everything it
// structurally can: a `#lua-match?` meant to pick out constants paints
// every identifier as one.
//
// Exits 1 when a query has a problem and 2 when the package cannot be
// checked at all.
package main

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"unsafe"

	"github.com/ebitengine/purego"
	tree_sitter "github.com/tree-sitter/go-tree-sitter"
)

// loadedQueries maps the query files Rune loads to the general predicates
// it evaluates in them. go-tree-sitter itself evaluates #eq?, #match?,
// #any-of? and their variants in every query, and #set! only sets
// properties, so none of them reach this list. Other .scm files, such as
// tags.scm, are only compiled. Keep in sync with
// internal/ide/syntax/treesitter in Rune.
var loadedQueries = map[string][]string{
	"highlights.scm": nil,
	"indents.scm":    nil,
	"folds.scm":      nil,
	"locals.scm":     nil,
	"injections.scm": {"offset!"},
}

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "usage: verify-queries <lib-dir> <lang>")
		os.Exit(2)
	}
	libDir, langID := os.Args[1], os.Args[2]
	lang, err := loadLanguage(filepath.Join(libDir, "tree-sitter.so"), langID)
	if err != nil {
		fmt.Fprintf(os.Stderr, "verify-queries: %s: %v\n", langID, err)
		os.Exit(2)
	}
	paths, err := filepath.Glob(filepath.Join(libDir, "*.scm"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "verify-queries: %s: %v\n", langID, err)
		os.Exit(2)
	}

	failed := false
	for _, path := range paths {
		name := filepath.Base(path)
		// Named before compiling so a query that aborts the process is
		// still the last thing in the build log.
		fmt.Printf("verify-queries: %s/%s ... ", langID, name)
		text, err := os.ReadFile(path)
		if err != nil {
			fmt.Println()
			fmt.Fprintf(os.Stderr, "verify-queries: %v\n", err)
			os.Exit(2)
		}
		problems := verify(lang, name, text)
		if len(problems) == 0 {
			fmt.Println("ok")
			continue
		}
		failed = true
		fmt.Println("FAIL")
		for _, p := range problems {
			fmt.Printf("  %s/%s: %s\n", langID, name, p)
		}
	}
	if failed {
		os.Exit(1)
	}
}

func loadLanguage(parser, langID string) (*tree_sitter.Language, error) {
	if resolved, err := filepath.EvalSymlinks(parser); err == nil {
		parser = resolved
	}
	lib, err := purego.Dlopen(parser, purego.RTLD_NOW|purego.RTLD_GLOBAL)
	if err != nil {
		return nil, fmt.Errorf("dlopen %q: %w", parser, err)
	}
	sym, err := purego.Dlsym(lib, "tree_sitter_"+langID)
	if err != nil {
		return nil, fmt.Errorf("load symbol: %w", err)
	}
	var language func() uintptr
	purego.RegisterFunc(&language, sym)
	return tree_sitter.NewLanguage(unsafe.Pointer(language())), nil
}

// verify returns the problems Rune would have with query file name.
func verify(lang *tree_sitter.Language, name string, text []byte) []string {
	query, qerr := tree_sitter.NewQuery(lang, string(text))
	if qerr != nil {
		return []string{qerr.Error()}
	}
	defer query.Close()

	evaluated, loaded := loadedQueries[name]
	if !loaded {
		return nil
	}
	var problems []string
	for i := range query.PatternCount() {
		line := bytes.Count(text[:query.StartByteForPattern(i)], []byte("\n")) + 1
		for _, p := range query.GeneralPredicates(i) {
			if !slices.Contains(evaluated, p.Operator) {
				problems = append(problems,
					fmt.Sprintf("line %d: #%s is not evaluated by Rune", line, p.Operator))
			}
		}
		for _, p := range query.PropertyPredicates(i) {
			op := "is?"
			if !p.Positive {
				op = "is-not?"
			}
			problems = append(problems,
				fmt.Sprintf("line %d: #%s %s is not evaluated by Rune", line, op, p.Property.Key))
		}
	}
	return problems
}
