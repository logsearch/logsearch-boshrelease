#!/bin/bash

set -e
set -u

cd src/

RELEASE_DIR=$PWD /usr/local/logsearch-shipper-release-utils/bin/test
