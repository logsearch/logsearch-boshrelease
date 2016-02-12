---
title: "Performing a Rolling Restart of Elasticsearch"
---

When doing a regular `bosh deploy` BOSH drain scripts usually takes care of managing a safe, rolling restart of
elasticsearch restarts, but sometimes you'll want to do this manually or will want to attempt this if the cluster is
misbehaving. This process can take a long time depending on when the nodes were restarted.

There's a [committed script][1] that you can download and run which makes this easy. It simply asks the cluster for all
the known nodes, going through and restarting all the master and data nodes (master nodes first, per
[elasticsearch recommendations][2]). Generally speaking, you should prefer to run this on a stable, green cluster.

    $ curl https://raw.githubusercontent.com/logsearch/logsearch-boshrelease/develop/share/util/elasticsearch-rolling-restart > elasticsearch-rolling-restart
    $ chmod +x elasticsearch-rolling-restart
    $ ./elasticsearch-rolling-restart api.cityindex.logsearch.io:9200
    2014-11-12T20:59:29Z > restarting api/0
    2014-11-12T20:59:29Z   > disabling allocations
    2014-11-12T20:59:30Z   > sending shutdown to 1f6dfccd-c887-48f9-8035-76e8a9d5c540
    2014-11-12T20:59:32Z   > waiting for node to leave
    2014-11-12T20:59:35Z   > waiting for node to rejoin
    2014-11-12T20:59:56Z   > enabling allocations
    2014-11-12T20:59:57Z   > waiting for green
    ...snip...
    2014-11-12T21:00:24Z > restarting elasticsearch_eu-west-1a/0
    2014-11-12T21:00:24Z   > disabling allocations
    2014-11-12T21:00:25Z   > sending shutdown to 3b705c71-fb6b-4cda-807f-f474ba70c626
    2014-11-12T21:00:26Z   > waiting for node to leave
    2014-11-12T21:00:31Z   > waiting for node to rejoin
    2014-11-12T21:00:46Z   > enabling allocations
    2014-11-12T21:00:49Z   > waiting for green
    ...snip...

This script disables allocation while a node is going down. If the script dies before it's able to re-enable
allocations, you'll need to completely rerun the script, or [manually re-enable allocations][3] before elasticsearch
will ever become green.


 [1]: https://github.com/logsearch/logsearch-boshrelease/blob/develop/share/util/elasticsearch-rolling-restart
 [2]: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-shutdown.html#_rolling_restart_of_nodes_full_cluster_restart
 [3]: https://github.com/logsearch/logsearch-boshrelease/blob/8641934395189325a663911127adbbc9f8f7660d/share/util/elasticsearch-rolling-restart#L63-L65
