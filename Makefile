.PHONY: build
build:
	stack build

.PHONY: install
install:
	stack install

.PHONY: run
run: install
	stack exec gear-watch
