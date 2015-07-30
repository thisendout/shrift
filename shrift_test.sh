#!/bin/bash

source ./test/lib/assert.sh
source ./shrift ./test/fixtures/blank_spec.sh

# test _usage
assert "_usage | head -n1 | cut -d ' ' -f1" "usage:"

# test _error
assert "_error test" "${RED}ERROR${END}: test"

# test _print_result
assert "_print_result 0" "${GREEN}.${END}"
assert "_print_result 1" "${RED}F${END}"
assert "_print_result 255" "${RED}F${END}"

# test _run_spec
assert "_run_spec true" "${GREEN}.${END}"
assert "_run_spec false" "${RED}F${END}"

assert_raises "./shrift" 1
assert_raises "./shrift -h" 0
assert_raises "./shrift | grep -q 'usage: '" 0
assert_raises "./shrift -h | grep -q 'usage: '" 0
assert "./shrift test/fixtures/pass_spec.sh" "${GREEN}.${END}"
assert "./shrift test/fixtures/fail_spec.sh" "${RED}F${END}"

assert_end examples
