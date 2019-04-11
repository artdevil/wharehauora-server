#!/bin/sh

# this script packages up all the binaries, and a script (deploy.sh)
# to twiddle with the server and the binaries

APP="$0"
STAGE="$1"

cd $TRAVIS_BUILD_DIR
openssl aes-256-cbc -k $DEPLOY_KEY -in $TRAVIS_BUILD_DIR/config/deploy_id_rsa_enc_travis -d -a -out $TRAVIS_BUILD_DIR/config/deploy_id_rsa
export WHAREHAUORA_STAGING_KEY_PEM=$TRAVIS_BUILD_DIR/config/deploy_id_rsa
RAILS_ENV=development bundle exec cap $STAGE deploy