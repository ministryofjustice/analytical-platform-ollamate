#!/usr/bin/env sh

# This is a helper script used in Analytical Platform Ollamate Kubernetes deployment
# It copies the static assets into a shared volume for the NGINX container to serve

export STATIC_SRC="${STATIC_SRC:-"/ollamate/run/static"}"
export STATIC_DEST="${STATIC_DEST:-"/staticfiles"}"

cp -R "${STATIC_SRC}" "${STATIC_DEST}"
