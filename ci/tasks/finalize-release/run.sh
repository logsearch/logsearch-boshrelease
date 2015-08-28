#!/bin/bash

set -e
set -u

VERSION=$( cat version/number )

cd repo


#
# we'll be updating the blobstore
#

cat > config/private.yml << EOF
---
blobstore:
  s3:
    access_key_id: $AWS_ACCESS_KEY
    secret_access_key: $AWS_SECRET_KEY
EOF


#
# finalize the release
#

bosh -n finalize release \
  ../release/tarball.tgz \
  --version="$VERSION"


#
# commit final release
#

git config user.email "${CI_EMAIL:-ci@localhost}"
git config user.name "${CI_NAME:-CI Bot}"

git add -A .final_builds releases

(
  echo "Release v$VERSION"
  echo ""
  cat releases/logsearch-$VERSION.md
) \
  | git commit -F-


#
# write out some release metadata for concourse
#

echo "v$VERSION" > ../name
cp releases/logsearch-$VERSION.md ../notes.md
git rev-parse HEAD > ../commit


#
# create an archive of the source code
#

mkdir -p releases-src/logsearch

COMMIT=$( git rev-parse HEAD )
COMMIT_SHORT=$( echo $COMMIT | cut -c -10 )

git archive \
  --format=tar.gz \
  --prefix=logsearch-$COMMIT_SHORT/ \
  $COMMIT \
  > releases-src/logsearch/logsearch-src-$VERSION.tgz
