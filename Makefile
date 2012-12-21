REPORTER=spec
INTERFACE=tdd
COMPILERS=coffee:coffee-script
FOLDERS=test/*.coffee

all: build

build:
	@./node_modules/coffee-script/bin/coffee \
		-c \
		-o lib src

clean:

docs: 
	@./node_modules/coffeedoc/bin/coffeedoc helpers/

watch:
	@./node_modules/coffee-script/bin/coffee \
		-o lib \
		-cw src

test:
	@./node_modules/mocha/bin/mocha --require should --reporter $(REPORTER) --ui $(INTERFACE) --compilers $(COMPILERS) $(FOLDERS)

.PHONY: build clean watch test