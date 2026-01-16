LANG ?= rust
REPO ?= github.com:tree-sitter/tree-sitter-$(LANG)
SRC=$(LANG) tools tree-sitter-$(LANG)
LIB=pkg/lib/tree-sitter.so pkg/lib/highlights.scm
TAR=$(LANG).tar.gz
CC=gcc

.PHONY: dist clean
default: $(TAR)

$(SRC):
    # create dir if not created already with a repository
    # to compile standard tools.
	mkdir -p pkg/bin pkg/lib $(LANG) tools
	-git submodule add $(REPO)

$(LIB): $(SRC)
	cd tree-sitter-$(LANG) && $(CC) -o parser.so -I./src src/*.c -Os -bundle -arch arm64 -arch x86_64
	cp tree-sitter-$(LANG)/parser.so pkg/lib/tree-sitter.so
	cp tree-sitter-$(LANG)/queries/highlights.scm pkg/lib
	@-cp tree-sitter-$(LANG)/queries/tags.scm pkg/lib
	@-cp nvim-treesitter/runtime/queries/$(LANG)/indents.scm pkg/lib
	@-cp nvim-treesitter/runtime/queries/$(LANG)/folds.scm pkg/lib
	@-cp nvim-treesitter/runtime/queries/$(LANG)/locals.scm pkg/lib
	@-cp src/*.scm pkg/lib

$(TAR): $(LIB)
	cd pkg && tar -czvf ../$(LANG).tar.gz .

dist: $(TAR)
	@ ./dist.sh

clean:
	rm -rf *.tar.gz
	rm -rf pkg
	mkdir -p pkg/bin pkg/lib $(LANG) tools
