#!/bin/bash -ex

ES_URI=${ES_URI:?"env ES_URI must be set"}
ASSIGN_TO_NODE=${ASSIGN_TO_NODE:?"env ASSIGN_TO_NODE must be set"}

function reroute() {
    curl -XPOST "${ES_URI}/_cluster/reroute?pretty" -d '{
        "commands" : [ {
                "allocate" : {
                    "index" : "'$1'",
                    "shard" : '$2'
                    "node" : "'${ASSIGN_TO_NODE}'"
                }
            }
        ]
    }' > /dev/null
    sleep 100
}
curl -s ${ES_URI}/_cluster/state?pretty | awk '
    BEGIN {more=1}
    {if (/"UNASSIGNED"/) unassigned=1}
    {if (/"routing_nodes"/) more=0}
    {if (unassigned && /"shard"/) shard=$3}
    {if (more && unassigned && /"index"/) {print "reroute",$3, shard; unassigned=false}}
' > runit
source runit