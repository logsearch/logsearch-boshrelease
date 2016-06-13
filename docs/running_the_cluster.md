# Running the cluster

## Rolling out updates

It is advised not to update more VM's at a time than the number of replicas. However, not all indices may have the same replication configuration.

The elasticsearch job in the BOSH release comes with a drain script that toggles replica relocation off and on during node updates.  This saves lots of time when upgrading a cluster with huge indices and may help to avoid losing shards temporarily, because it prevents Elasticsearch attempting to recover shards to other nodes which will re-appear once the node being upgraded restarts anyway). Turning the feature on in the deployment manifest is highly recommended.

```yaml
jobs:
- name: elasticsearch_data
  properties:
    elasticsearch:
      drain: true
  update:
    max_in_flight: 1
```

### Running out of Disk

In the rare occasion that a single data node starts running out of disk, you should see elasticsearch start to evacuate shards onto other nodes.

When more than one, or all of the data nodes start to get full, it is recommended that more data nodes are added to the cluster. Once the cluster stabilizes after this scale up, individual nodes can then be upgraded with larger disks. This procedure is similar to rolling updates out.

The kopf UI provides resource information about each node including disk usage.

## Scaling the cluster up

Scaling Elasticsearch is a rather involved process with no "right" answers.  Start by reading through the [official Elastic documentation on the topic](https://www.elastic.co/guide/en/elasticsearch/guide/current/scale.html)

With that background, here is how you make some common scaling changes with Logsearch.

### Increasing the Elasticsearch data nodes

Increment the number of `elasticsearch_data` node instances in your stub
```yaml
- name: elasticsearch_data
  instances: 10
```
followed by `bosh deploy`.  Once the new nodes have been provisioned Elasticsearch will automatically begin balancing shards between them (this can take *many hours*; but your cluster will remain functional throughout)

### Customising number of shards and replicas

As a rough rule of thumb you will probably want to change the number of shards and replicas in your cluster so that `NUMBER_OF_SHARDS` * `NUMBER_OF_REPLICAS` == `number of elasticsearch_data` nodes

To change the default number of shards (`NUMBER_OF_SHARDS`) and replicas (`NUMBER_OF_REPLICAS`), update the maintenance job in your stub with:

```yaml
- name: maintenance
  instances: 1
  properties:
    elasticsearch_config:
      templates:
      - shards-and-replicas: "{ \"template\" : \"*\", \"order\" : 99, \"settings\" : { \"number_of_shards\" : NUMBER_OF_SHARDS, \"number_of_replicas\" : NUMBER_OF_REPLICAS } }"
```

**NB** This changes the default shard and replica settings; which will only be applied to **new** indexes.  It isn't possible to change the number of shards for existing indexes.

## Scaling the cluster down

### Cowboy downgrade

Just shut down data nodes. This will cause the cluster to go yellow until the missing shard copies are recreated. Do not remove more data nodes than the number of replicas at one time though.

### Bulletproof downgrade

Evacuate data from data nodes that are to be taken offline by rerouting shards off it:

```
curl -XPUT MASTER_NODE:9200/_cluster/settings -d '{
  "transient" : {
      "cluster.routing.allocation.exclude._ip" : "DATA_NODE_IP,DATA_NODE2_IP"
  }
}'
```

Wait until the node is empty then remove the IP from the deployment manifest.

NOTE: BOSH can not remove jobs from the middle of the list without reshuffling the rest of the VM IP's so the best way is to remove nodes starting from the end.

After finished with scaling lift the routing exclusion:

```
curl -XPUT MASTER_NODE:9200/_cluster/settings -d '{
  "transient" : {
      "cluster.routing.allocation.exclude._ip" : ""
  }
}'
```

