#!/bin/bash

set -e
set -u

. /usr/local/testutils/etc/load-env

STANDALONE_IP=$( silo-host 0.standalone.silo-private.logsearch-standalone-test.bosh )
SHIPPER_IP=$( silo-host 0.shipper.silo-private.logsearch-standalone-test.bosh )

install-packages \
  "${SHIPPER_IP}" \
  "logsearch/$( cat release/version )" \
  $( get-deployment-stemcell logsearch-standalone-test ) \
  java8 logstash

ssh "vcap@${SHIPPER_IP}" <<"EOF" | tee shipper.log
  set -e
  export PATH="/var/vcap/packages/java8/bin:$PATH"
  [ ! -e /home/vcap/.sincedb ] || rm /home/vcap/.sincedb
  curl -X DELETE '0.standalone.silo-private.logsearch-standalone-test.bosh:9200/_all' > /dev/null
  sudo /var/vcap/packages/logstash/logstash/bin/plugin install logstash-output-syslog
  sudo /var/vcap/packages/logstash/logstash/bin/logstash \
    --config logstash.conf
  sleep 5
  curl -X POST '0.standalone.silo-private.logsearch-standalone-test.bosh:9200/_refresh' > /dev/null
  curl -s '0.standalone.silo-private.logsearch-standalone-test.bosh:9200/_search?size=1024&pretty'
  sleep 5
EOF

echo ""

#
# now review our results
#

if ! grep '"total" : 33' shipper.log > /dev/null 2>&1 ; then
  fail 'Failed to capture expected number of messages'
fi

TESTLINE=$( grep '9d666a0da317777d35e763800ddfd8507cfb580c b056061ab74cc30ee2e6ea3e530f7262b2245228 2015-05-28 18:36:28 -0600 Danny Berger // Start experimenting with concourse' shipper.log )

if ! echo "${TESTLINE}" | grep '"commit":"9d666a0da317777d35e763800ddfd8507cfb580c"' > /dev/null 2>&1 ; then
  fail 'Failed to capture commit field'
elif ! echo "${TESTLINE}" | grep '"parents":\["b056061ab74cc30ee2e6ea3e530f7262b2245228"\]' > /dev/null 2>&1 ; then
  fail 'Failed to capture parent field'
fi

echo "SUCCESS"
