module github.com/unstablebuild/rune-language-template/tools/verify-queries

go 1.25.0

require (
	github.com/ebitengine/purego v0.11.0
	github.com/tree-sitter/go-tree-sitter v0.25.0
)

require github.com/mattn/go-pointer v0.0.1 // indirect

// The go-tree-sitter Rune links. Keep in sync with Rune's go.mod so the
// check compiles queries exactly as Rune does.
replace github.com/tree-sitter/go-tree-sitter => github.com/unstablebuild/go-tree-sitter v0.25.0-ub.3
