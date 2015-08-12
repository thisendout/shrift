#!/bin/bash

__dummy_version=0.1.0

# define variables
__dummy_red='\033[0;31m'
__dummy_green='\033[0;32m'
__dummy_clear='\033[0m'
__dummy_cmdrc=0
__dummy_cmdout=.__dummy_cmdout
__dummy_debug=0
__dummy_debug_out=.__dummy_debug
__dummy_verbose=0
__dummy_nocolor=0
__dummy_tests=0
__dummy_failed_tests=0
__dummy_start_time=$(date +%s)

# global functions
describe() {
  echo $1
}

cmd() {
  ( set +e; eval "${1}" 2>&1 > $__dummy_cmdout ) \
    && __dummy_cmdrc=0 || __dummy_cmdrc=$?
}

assert_rc() {
  echo $__dummy_cmdrc
  echo $1
  if [ $__dummy_cmdrc -ne $1 ]; then
    echo "hello"
    if [ $__dummy_verbose -eq 1 ]; then
      echo "expecting return code '${1}'"
      echo "got return code '${__dummy_cmdrc}'"
    fi
    return $__dummy_cmdrc
  fi
}

assert_content() {
  grep "${1}" $__dummy_cmdout
  return $?
}

assert_regex() {
  grep -E "${1}" $__dummy_cmdout
  return $?
}

# private functions
__dummy_error() {
  echo -e "${__dummy_red}ERROR: $1${__dummy_clear}"
  exit 1
}

__dummy_print_status() {
  case $2 in
    PASS) s="${__dummy_green}PASS${__dummy_clear}";;
    FAIL) s="${__dummy_red}FAIL${__dummy_clear}";;
  esac
  printf "  %-51s [${s}]\n" "$1"
  if [[ $2 == "FAIL" ]]; then
    if [ $__dummy_debug -eq 1 ]; then
      while read output;
        do echo "    ${output}";
      done < $__dummy_debug_out
    fi
  fi
}

__dummy_print_summary() {
  printf "%60s\n" | tr " " "-"
  printf "Tests:  %3d  |  " $__dummy_tests
  printf "Passed:  %3d  |  " $(($__dummy_tests - $__dummy_failed_tests))
  printf "Failed: %3d  |  " $__dummy_failed_tests
  printf "Time: %3ds" $((`date +%s` - $__dummy_start_time))
  printf "\n"
}

__dummy_run_test() {
  local rc=0
  __dummy_cmdrc=0
  > $__dummy_cmdout
  > $__dummy_debug_out
  set +e
  (
    set -ex
    eval ${1}
  ) &> $__dummy_debug_out
  rc=$?
  set +ex
  if [ $rc -eq 0 ]; then
    __dummy_print_status $1 PASS
  else
    __dummy_print_status $1 FAIL
    let __dummy_failed_tests+=1
  fi
  let __dummy_tests+=1
  rm $__dummy_debug_out
}

# parse cli args
until [ -z $1 ]; do
  case $1 in
    -d|--debug)   __dummy_debug=1; __dummy_verbose=1;;
    -v|--verbose) __dummy_verbose=1;;
    --nocolor)    __dummy_nocolor=1;;
    *)            __dummy_specfile=$1;;
  esac
  shift
done

# disable color
if [ $__dummy_nocolor -eq 1 ]; then
  __dummy_red=''
  __dummy_green=''
  __dummy_clear=''
fi

# ensure we can read the spec
[ -f ${__dummy_specfile} ] || __dummy_error "No such file ${__dummy_specfile}"
[ -r ${__dummy_specfile} ] || __dummy_error "Cannot read ${__dummy_specfile}"

# source the spec functions
source ${__dummy_specfile} 2>&1 > /dev/null

# call the spec functions
while read line; do
  if echo $line | grep -q '^it_'; then
    t=$(echo $line | cut -d'(' -f1)
    if grep -B1 $t ${__dummy_specfile} | grep -q '^describe '; then
      eval $(grep -B1 $t ${__dummy_specfile} | grep '^describe ')
    elif grep -B1 $t ${__dummy_specfile} | grep -q '^$'; then
      echo
    fi
    __dummy_run_test "${t}"
  fi
done < ${__dummy_specfile}

# print summary
__dummy_print_summary

# exit if failed tests
[ $__dummy_failed_tests -eq 0 ] || exit 1
