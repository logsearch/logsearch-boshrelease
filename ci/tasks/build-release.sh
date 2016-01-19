#!/bin/bash -ex

version="$(cat logsearch-version/number)"

cd logsearch-boshrelease/src/logsearch-config
rake build

cd ../..
bosh create release --force --with-tarball --name logsearch --version "$version"
