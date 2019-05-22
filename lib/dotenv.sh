#!/usr/bin/env bash
#
# This is a bash implementation of the popular `dotenv` interface, where the environment variables
# for a program are defined on a file named `.env` on the root folder and each application reads
# them before starting.
#
# Source this file on the beginning of each shell script so they have access to the right
# environment variables.
#
# This script supports overriding the .env variables by the ones present in the current environment,
# so if you need to do it, just define them (i.e. execute the script with VAR=value ./script) or
# export them beforehand.

# Let's get the current variables before modifying the scope
env="$(printenv | sed -E 's/=(.*)/="\1"/')"

set -a

# shellcheck disable=SC1091
source ".env"
set +a

# Re-set the previous variables so we don't override them
eval "$env"
unset env
