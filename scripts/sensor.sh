#!/bin/sh

# this script for running background sensor read

APP="$0"
STAGE="$1"
PIDFILE="$2"

bundle exec rake sensors:ingest BACKGROUND=true LOG_LEVEL=info PIDFILE=$PIDFILE RAILS_ENV=$STAGE;