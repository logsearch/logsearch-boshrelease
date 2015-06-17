#!/bin/bash

set -e
set -u

echo "Compiling template..."

cd repo/

REPODIR="${PWD}"

[ ! -e target/logstash-filters ] || rm -fr target/logstash-filters

mkdir -p target/logstash-filters

mkdir target/logstash-filters/snippets
cp src/logstash-filters/snippets/* target/logstash-filters/snippets/

erb src/logstash-filters/default.conf.erb > target/logstash-filters/default.conf

echo "Running tests..."

cd /usr/local/logstash/

./bin/rspec $(find "${REPODIR}/test" -name *spec.rb)
