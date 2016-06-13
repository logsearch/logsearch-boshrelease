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

## Customising number of shards and replicas

To change the default number of shards (5) and replicas (1), update the maintenance job in your stub to:

```yaml
- name: maintenance
  instances: 1
  properties:
    elasticsearch_config:
      templates:
      - shards-and-replicas: "{ \"template\" : \"*\", \"order\" : 99, \"settings\" : { \"number_of_shards\" : NUMBER_OF_SHARDS, \"number_of_replicas\" : NUMBER_OF_REPLICAS } }"
```

## Scaling the cluster up

Just add more data nodes.

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

