#!/bin/sh

# Build the source code in an unpacked tarball

# Copyright (c)2013 by Brian Manning (brian at xaoc dot org)
# License terms are listed at the bottom of this file
#
# Impotant URLs:
# Clone:    https://github.com/spicyjack/jenkins-cfg.git
# Issues:   https://github.com/spicyjack/jenkins-cfg/issues

### MAIN SCRIPT ###
# what's my name?
SCRIPTNAME=$(basename $0)
TIME_CMD="/usr/bin/time"

# run 'make test'?
RUN_MAKE_TEST=0

# verbose script output by default
QUIET=0

# default exit status
EXIT_STATUS=0

### SCRIPT SETUP ###
# source jenkins functions
. ~/src/jenkins-cfg.git/scripts/common_jenkins_functions.sh

#check_env_variable "$PRIVATE_STAMP_DIR" "PRIVATE_STAMP_DIR"
#check_env_variable "$PUBLIC_STAMP_DIR" "PUBLIC_STAMP_DIR"

GETOPT_SHORT="hqs:"
GETOPT_LONG="help,quiet,source:"
# sets GETOPT_TEMP
# pass in $@ unquoted so it expands, and run_getopt() will then quote it "$@"
# when it goes to re-parse script arguments
run_getopt "$GETOPT_SHORT" "$GETOPT_LONG" $@

show_help () {
cat <<-EOF

    ${SCRIPTNAME} [options]

    SCRIPT OPTIONS
    -h|--help       Displays this help message
    -q|--quiet      No script output (unless an error occurs)
    -s|--source     Path to the unpacked source code directory
    -t|--test       Run 'make test' after running 'make'; 
                    not all source code supports running 'make test'

    Example usage:
    ${SCRIPTNAME} --path /path/to/source/of/libfoo-0.1.2
EOF
}

# Note the quotes around `$TEMP': they are essential!
# read in the $TEMP variable
eval set -- "$GETOPT_TEMP"

# read in command line options and set appropriate environment variables
while true ; do
    case "$1" in
        # show the script options
        -h|--help)
            show_help
            exit 0;;
        # don't output anything (unless there's an error)
        -q|--quiet)
            QUIET=1
            shift;;
        # dependencies to check for
        -p|--path)
            SOURCE_PATH="$2";
            shift 2;;
        # dependencies to check for
        -t|--test|--make-test)
            RUN_MAKE_TEST=1;
            shift;;
        # separator between options and arguments
        --)
            shift;
            break;;
        # we shouldn't get here; die gracefully
        *)
            warn "ERROR: unknown option '$1'"
            warn "ERROR: use --help to see all script options"
            exit 1
            ;;
    esac
done

if [ "x$SOURCE_PATH" = "x" ]; then
    warn "ERROR: Please pass a path to the unpacked source directory (--path)"
    exit 1
fi

if [ ! -d "$SOURCE_PATH" ]; then
    warn "ERROR: unpacked source path ${SOURCE_PATH} does not exist"
    exit 1
fi

### SCRIPT MAIN LOOP ###
show_script_header
if [ $RUN_MAKE_TEST -eq 0 ]; then
    info "Running 'make; make install' in path: ${SOURCE_PATH}"
    MAKE_CMD="${TIME} make; ${TIME} make install"
else
    info "Running 'make; make install' in path: ${SOURCE_PATH}"
    MAKE_CMD="${TIME} make; ${TIME} make install"
fi
    
START_DIR=$PWD
cd $SOURCE_PATH
OUTPUT=$(git pull 2>&1)
say "git: ${OUTPUT}"
EXIT_STATUS=$?
cd $START_DIR

if [ $EXIT_STATUS -gt 0 ]; then
    warn "ERROR: jenkins-cfg.git repo was not updated"
fi

exit $EXIT_STATUS

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

# vi: set filetype=sh shiftwidth=4 tabstop=4
# end of line