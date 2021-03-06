#!/bin/sh

# this script packages up all the binaries, and a script (deploy.sh)
# to twiddle with the server and the binaries

STAGE="$1"

"openssl aes-256-cbc -k $DEPLOY_KEY -in config/deploy_id_rsa_enc_travis -d -a -out config/deploy_id_rsa"
export WHAREHAUORA_KEY_PEM="$TRAVIS_BUILD_DIR/config/deploy_id_rsa"
"bundle exec cap $STAGE deploy"