#!/bin/sh

# this script packages up all the binaries, and a script (deploy.sh)
# to twiddle with the server and the binaries

APP="$0"
STAGE="$1"

cap $STAGE deploy