#!/bin/sh

# this script for running background sensor read

APP="$0"
STAGE="$1"
PATH_DEPLOY="$2"
PIDFILE="$3"

cd $PATH_DEPLOY && RAILS_ENV=$STAGE BACKGROUND=true LOG_LEVEL=info PIDFILE=$PIDFILE bundle exec rake sensors:ingest