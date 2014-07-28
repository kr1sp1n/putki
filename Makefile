.PHONY: test

MOCHA_BIN = ./node_modules/.bin/mocha
TEST_DIR = ./test
UNIT_TEST_DIR = $(TEST_DIR)/unit

install:
	npm install .

start:
	npm start

test: test-unit

test-unit:
	$(MOCHA_BIN) $(UNIT_TEST_DIR) --recursive

watch:
	$(MOCHA_BIN) $(UNIT_TEST_DIR) --recursive --reporter min --watch --growl
