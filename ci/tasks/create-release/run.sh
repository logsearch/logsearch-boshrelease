#!/bin/bash

set -e
set -u

cd "${PWD}/repo"

bosh -n create release \
  --version="$( cat ../version/number )" \
  --with-tarball
