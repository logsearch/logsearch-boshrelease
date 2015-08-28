#!/bin/bash

set -e
set -u

bosh -n target "${BOSH_TARGET}"
bosh -n login "${BOSH_USERNAME}" "${BOSH_PASSWORD}"
bosh -n download manifest "${DEPLOYMENT_NAME}" > manifest.yml

bosh \
  -n \
  -d manifest.yml \
  run errand \
  "${ERRAND_NAME}"
