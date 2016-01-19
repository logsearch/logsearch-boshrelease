#!/bin/bash -x

cd logsearch-boshrelease/src/logsearch-config

bin/install-dependencies
vendor/logstash/vendor/jruby/bin/jruby -S rake build

export SPEC_OPTS="--format documentation"
vendor/logstash/vendor/jruby/bin/jruby -S rake test
