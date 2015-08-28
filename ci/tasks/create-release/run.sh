#!/bin/bash

set -e
set -u

VERSION=$( cat version/number )

cd repo


#
# create a dev release
#

bosh -n create release \
  --version="$VERSION" \
  --with-tarball


#
# create an archive of the source code
#

mkdir -p dev_releases-src/logsearch

COMMIT=$( git rev-parse HEAD )
COMMIT_SHORT=$( echo $COMMIT | cut -c -10 )

git archive \
  --format=tar.gz \
  --prefix=logsearch-$COMMIT_SHORT/ \
  $COMMIT \
  > dev_releases-src/logsearch/logsearch-src-$VERSION.tgz
