#!/bin/bash

source ./test/lib/assert.sh
source ./shrift

# test _usage
assert "_usage | head -n1 | cut -d ' ' -f1" "usage:"

# test _error
assert "_error test" "${RED}ERROR: test${END}"

# test _mktemp
t=$(_mktemp)
assert_raises "test -f ${t}" 0
rm $t

# test _print_cmd_summary
assert "_print_cmd_summary 0 'good'" "  (${GREEN}0${END}) ${GREEN}good${END}"
assert "_print_cmd_summary 1 'bad'" "  (${RED}1${END}) ${RED}bad${END}"
assert "_print_cmd_summary 255 'also bad'" "  (${RED}255${END}) ${RED}also bad${END}"

# test _print_cmd_output
t=$(_mktemp)
echo -e "command not found: banana" > $t
assert "_print_cmd_output $t" "    command not found: banana\n"
echo -e "command not found: barnana" >> $t
assert "_print_cmd_output $t" "    command not found: banana\n    command not found: barnana\n"
rm $t

# test _print_dot
assert "_print_dot 0" "${GREEN}.${END}"
assert "_print_dot 1" "${RED}F${END}"
assert "_print_dot 255" "${RED}F${END}"

# test _main output
assert "_main test/fixtures/pass_spec.sh" "\n${GREEN}.${END}${GREEN}.${END}\n2 tests, 0 failed"
assert "_main test/fixtures/fail_spec.sh" "\n  (${RED}1${END}) ${RED}test -f notpresent${END}\n\n${RED}F${END}\n1 tests, 1 failed"
assert "_main -v test/fixtures/pass_spec.sh" "\n  (${GREEN}0${END}) ${GREEN}test -f ./shrift${END}\n  (${GREEN}0${END}) ${GREEN}test -f ./shrift_test.sh${END}\n\n${GREEN}.${END}${GREEN}.${END}\n2 tests, 0 failed"
assert "_main test/fixtures" "\n  (${RED}1${END}) ${RED}test -f notpresent${END}\n\n${RED}F${END}${GREEN}.${END}${GREEN}.${END}\n3 tests, 1 failed"
assert "_main test/**/*_spec.sh" "\n  (${RED}1${END}) ${RED}test -f notpresent${END}\n\n${RED}F${END}${GREEN}.${END}${GREEN}.${END}\n3 tests, 1 failed"
assert "_main test/fixtures/*_spec.sh" "\n  (${RED}1${END}) ${RED}test -f notpresent${END}\n\n${RED}F${END}${GREEN}.${END}${GREEN}.${END}\n3 tests, 1 failed"

# test runtime usage
assert_raises "./shrift -h" 0
assert_raises "./shrift -h | grep -q 'usage: '" 0

# test runtime output
assert "./shrift test/fixtures/pass_spec.sh" "\n${GREEN}.${END}${GREEN}.${END}\n2 tests, 0 failed\n"
assert "./shrift test/fixtures/fail_spec.sh" "\n  (${RED}1${END}) ${RED}test -f notpresent${END}\n\n${RED}F${END}\n1 tests, 1 failed\n"
assert "./shrift -v test/fixtures/pass_spec.sh" "\n  (${GREEN}0${END}) ${GREEN}test -f ./shrift${END}\n  (${GREEN}0${END}) ${GREEN}test -f ./shrift_test.sh${END}\n\n${GREEN}.${END}${GREEN}.${END}\n2 tests, 0 failed\n"

# test runtime return code
assert_raises "./shrift test/fixtures/pass_spec.sh" 0
assert_raises "./shrift test/fixtures/fail_spec.sh" 1

assert_end examples
