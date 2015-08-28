#!/bin/bash

set -e
set -u

cd src

bosh -n create release \
  --version=$( cat ../version/number ) \
  --with-tarball

cd ../

#
# move results to top-level and cleanup
#

mv src/src/dev_releases/*.tgz ./

rm -fr src version
