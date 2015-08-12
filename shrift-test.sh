#!/bin/bash

source ./shrift

# force no color output
RED=""
GREEN=""
END=""

describe "test _usage"
it_displays_usage_version() {
  cmd '_usage'
  assert_rc 0
  assert_content 'Version: '
  assert_content 'usage: '
}

describe "test _error"
it_prints_error_message() {
  cmd '_error test'
  assert_rc 1
  assert_content 'ERROR: test'
}

describe "test _mktmp"
it_makes_a_temp_directory() {
  t=$(_mktemp)
  test -f ${t} && rm $t
}

describe "test _print_cmd_summary"
it_prints_cmd_summary_rc0() {
  _print_cmd_summary 0 'good' | grep -F '(0) good'
}
it_prints_cmd_summary_rc1() {
  _print_cmd_summary 1 'bad' | grep -F '(1) bad'
}
it_prints_cmd_summary_rc255() {
  _print_cmd_summary 255 'bad' | grep -F '(255) bad'
}

describe "test _print_cmd_output"
it_prints_cmd_output() {
  t=$(_mktemp)
  echo -e "command not found: banana\ntry installing banana" > $t
  _print_cmd_output $t | grep '    command not found: banana'
  _print_cmd_output $t | grep '    try installing banana'
  rm $t
}

describe "test _print_dot"
it_prints_dot_rc0() {
  cmd "_print_dot 0"
  assert_rc 0
  assert_regex '^.$'
}
it_prints_dot_rc1() {
  cmd "_print_dot 1"
  assert_rc 0
  assert_regex '^F$'
}
it_prints_dot_rc255() {
  cmd "_print_dot 255"
  assert_rc 0
  assert_regex '^F$'
}

describe "test _main"
it_main_passes_good_spec() {
  cmd "_main test/fixtures/pass_spec.sh"
  assert_rc 0
  assert_content '2 tests, 0 failed'
}
it_main_fails_bad_spec() {
  cmd "_main test/fixtures/fail_spec.sh"
  assert_rc 1
  assert_content '1 tests, 1 failed'
}
it_main_runs_all_specs_in_dir() {
  cmd "_main test/fixtures"
  assert_rc 1
  assert_content '6 tests, 1 failed'
}
it_main_runs_all_globs() {
  cmd '_main test/**/*_spec.sh'
  assert_rc 1
  assert_content '6 tests, 1 failed'
}
it_main_runs_all_globs() {
  cmd '_main test/fixtures/*_spec.sh'
  assert_rc 1
  assert_content '6 tests, 1 failed'
}

describe "test runtime usage"
it_shrift_accepts_help_flag() {
  cmd './shrift -h'
  assert_rc 0
  assert_content 'usage: '
  cmd './shrift --help'
  assert_rc 0
  assert_content 'usage: '
}
it_shrift_passes_good_spec() {
  cmd './shrift test/fixtures/pass_spec.sh'
  assert_rc 0
  assert_content '2 tests, 0 failed'
}
it_shrift_fails_bad_spec() {
  cmd './shrift test/fixtures/fail_spec.sh'
  assert_rc 1
  assert_content '1 tests, 1 failed'
}
it_shrift_accepts_functions() {
  cmd './shrift -v test/fixtures/func_spec.sh'
  assert_rc 0
  assert_content '3 tests, 0 failed'
}
