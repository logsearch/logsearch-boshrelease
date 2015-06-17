#!/bin/bash

set -e
set -u

cd "${PWD}/repo"

bosh -n create release \
  --final \
  --version="$( cat ../version/number )" \
  --with-tarball
