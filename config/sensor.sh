#!/bin/sh

# this script packages up all the binaries, and a script (deploy.sh)
# to twiddle with the server and the binaries

APP="$0"
STAGE="$1"

~/.rvm/bin/rvm default do bundle exec rake sensors:ingest BACKGROUND=true LOG_LEVEL=info PIDFILE=/home/rails/apps/staging/wharehauora-server/shared/tmp/pids/sensors_read.pid RAILS_ENV=staging