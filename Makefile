.PHONY: build
build:
	stack build

.PHONY: install
install:
	stack install

.PHONY: run
run: install
	stack exec gear-watch

.PHONY: rebuild
rebuild:
	stack clean
	stack build

.PHONY: clean
clean:
	stack clean
	echo "" > .checked.txt
