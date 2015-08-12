#!/bin/bash

source ./shrift

# force no color output
RED=""
GREEN=""
END=""

# needed to not fail on return code
_safe_eval() {
  set +e && eval $1 && set -e
}

describe "test shrift"

# test _usage
it_displays_usage_version() {
  _usage | grep 'Version: '
}
it_displays_usage_info() {
  _usage | grep 'usage: '
}

# test _error
it_prints_error_message() {
  _error test | grep "ERROR: test"
}

# test _mktmp
it_makes_a_temp_directory() {
  t=$(_mktemp)
  test -f ${t} && rm $t
}

# test _print_cmd_summary
it_prints_cmd_summary_rc0() {
  _print_cmd_summary 0 'good' | grep -F '(0) good'
}
it_prints_cmd_summary_rc1() {
  _print_cmd_summary 1 'bad' | grep -F '(1) bad'
}
it_prints_cmd_summary_rc255() {
  _print_cmd_summary 255 'bad' | grep -F '(255) bad'
}

# test _print_cmd_output
it_prints_cmd_output() {
  t=$(_mktemp)
  echo "command not found: banana\ntry installing banana" > $t
  _print_cmd_output $t | grep '    command not found: banana'
  _print_cmd_output $t | grep '    try installing banana'
  rm $t
}

# test _print_dot
it_prints_dot_rc0() {
  _print_dot 0 | grep '.'
}
it_prints_dot_rc1() {
  _print_dot 1 | grep 'F'
}
it_prints_dot_rc255() {
  _print_dot 255 | grep 'F'
}

# test _main
it_main_passes_good_spec() {
  _safe_eval "_main test/fixtures/pass_spec.sh" | grep '2 tests, 0 failed'
}
it_main_fails_bad_spec() {
  _safe_eval "_main test/fixtures/fail_spec.sh" | grep '1 tests, 1 failed'
}
it_main_runs_all_specs_in_dir() {
  _safe_eval "_main test/fixtures" | grep '6 tests, 1 failed'
}
it_main_runs_all_globs() {
  _safe_eval '_main test/**/*_spec.sh' | grep '6 tests, 1 failed'
}
it_main_runs_all_globs() {
  _safe_eval '_main test/fixtures/*_spec.sh' | grep '6 tests, 1 failed'
}

# test runtime usage
it_shrift_accepts_help_flag() {
  _safe_eval './shrift -h' | grep 'usage: '
  _safe_eval './shrift --help' | grep 'usage: '
}
it_shrift_passes_good_spec() {
  _safe_eval './shrift test/fixtures/pass_spec.sh' | grep '2 tests, 0 failed'
}
it_shrift_fails_bad_spec() {
  _safe_eval './shrift test/fixtures/fail_spec.sh' | grep '1 tests, 1 failed'
}
it_shrift_accepts_functions() {
  _safe_eval './shrift -v test/fixtures/func_spec.sh' | grep '3 tests, 0 failed'
}
