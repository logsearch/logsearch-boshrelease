#!/bin/bash

set -e
set -u

bosh -n target ${BOSH_TARGET}
bosh -n login "${BOSH_USERNAME}" "${BOSH_PASSWORD}"

for RELEASE_FILE in $RELEASE_PATH ; do
  bosh -n upload release --skip-if-exists "${RELEASE_FILE}"
done

cd repo

bosh -d "${DEPLOYMENT_PATH}" -n deploy
