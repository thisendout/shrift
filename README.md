# shrift
[![Circle CI](https://circleci.com/gh/thisendout/shrift.svg?style=svg)](https://circleci.com/gh/thisendout/shrift)

shrift is a minimal spec framework for testing your infrastructure using bash.
shrift installs as a single script and executes bash one-liners as a test suite.
No complex setup.  No DSL.

# Quickstart

Download <code>shrift</code>.
```
# download the script
$ curl -L -o shrift https://github.com/thisendout/shrift/raw/master/shrift
# make executable
$ chmod +x shrift
```

Write and run your first spec.

```
# write a passing test
$ echo "test -x ./shrift" > test_spec.sh
# execute with shrift
$ ./shrift test_spec.sh
```

# Documentation

## Spec Files

By default, `shrift` searches for files matching *_spec.sh in the current directory.  You can pass a space-separated list of paths to shrift to expand the suite.

```
$ ./shrift specs                      # _spec.sh files in a sub-directory
$ ./shrift specs/{common,web}         # _spec.sh split up by role, one per directory
$ ./shrift specs/{common,web}_spec.sh # _spec.sh split up by role, one per file
$ ./shrift specs/**/*.sh              # globbing and wilcards are supported
```

## Specs

Spec files must contain one test per line.  A test is considered passing when the return code is `0`. Any other condition is considered a failure.

```
# example spec file
test -f /etc/passwd
whoami | grep root
/usr/local/bin/my_test_script
netstat -lntp | grep 80
```

### Functions

Spec files may source a functions file or contain user-defined inline functions (contained on a single line) to encapsulate commonly used commands. For example, if there were a number of spec's checking for individual ports, instead of repeating the command, a one-liner function could be used instead.

```
# before function
netstat -lntp | grep 22
netstat -lntp | grep 80
netstat -lntp | grep 443

# define function
port() { netstat -lntp | grep $1; }

# after function
port 22
port 80
port 443
```

Sourcing a common functions file is also a supported workflow. For example:

```
# my_functions.sh
function port() { netstat -lntp | grep $1; }
process() { ps ax | grep $1; }
mode() { stat -c "%a" $1 | grep $2; }

# my_spec.sh
source my_functions.sh
port 22
process sshd
mode /etc/passwd 644
```

## Targets

By default, `shrift` executes the specs locally.  shrift can also execute using docker exec and ssh, if the clients are already installed.

```
$ ./shrift -d [container_id]  # Run specs against a *running* container
$ ./shrift -s [hostname]      # Run specs against a remote host via SSH
```

For docker and ssh backends, custom client-specific options can be passed using `-o 'opts...'`.

For the ssh backends, each spec is executed using a separate ssh command. We recommend setting up ControlMaster and ControlPersist to re-use ssh sessions.

## Output

By default, `shrift` shows output from failing tests and a summary.  If you want to see the output from all tests, set the verbose flag by passing `-v`.

### Blocks

A `#` comment line will start a new test block.  `shrift` will add subsequent tests to the block until another comment or empty line is encountered.  Blocks are only used in formatting output; they do not modify how the tests are executed.

# License

MIT License

&copy; 2015 This End Out, LLC
