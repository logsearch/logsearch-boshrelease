---
title: "Elasticsearch"
---

## Metrics


### Effective Lag

 * [`logstash.search_lag`](./metric-lag.md) - effective search lag


### Internal Process Statisics

The following are forwarded from the internal elasticsearch metrics. See the [official Elasticsearch documentation][1]
for details about their meanings.

 * `elasticsearch.http.current_open`
 * `elasticsearch.http.total_opened`
 * `elasticsearch.indices.completion.size_in_bytes`
 * `elasticsearch.indices.docs.count`
 * `elasticsearch.indices.docs.deleted`
 * `elasticsearch.indices.fielddata.evictions`
 * `elasticsearch.indices.fielddata.memory_size_in_bytes`
 * `elasticsearch.indices.filter_cache.evictions`
 * `elasticsearch.indices.filter_cache.memory_size_in_bytes`
 * `elasticsearch.indices.flush.total`
 * `elasticsearch.indices.flush.total_time_in_millis`
 * `elasticsearch.indices.get.current`
 * `elasticsearch.indices.get.exists_time_in_millis`
 * `elasticsearch.indices.get.exists_total`
 * `elasticsearch.indices.get.missing_time_in_millis`
 * `elasticsearch.indices.get.missing_total`
 * `elasticsearch.indices.get.time_in_millis`
 * `elasticsearch.indices.get.total`
 * `elasticsearch.indices.id_cache.memory_size_in_bytes`
 * `elasticsearch.indices.indexing.delete_current`
 * `elasticsearch.indices.indexing.delete_time_in_millis`
 * `elasticsearch.indices.indexing.delete_total`
 * `elasticsearch.indices.indexing.index_current`
 * `elasticsearch.indices.indexing.index_time_in_millis`
 * `elasticsearch.indices.indexing.index_total`
 * `elasticsearch.indices.merges.current`
 * `elasticsearch.indices.merges.current_docs`
 * `elasticsearch.indices.merges.current_size_in_bytes`
 * `elasticsearch.indices.merges.total`
 * `elasticsearch.indices.merges.total_docs`
 * `elasticsearch.indices.merges.total_size_in_bytes`
 * `elasticsearch.indices.merges.total_time_in_millis`
 * `elasticsearch.indices.percolate.current`
 * `elasticsearch.indices.percolate.memory_size_in_bytes`
 * `elasticsearch.indices.percolate.queries`
 * `elasticsearch.indices.percolate.time_in_millis`
 * `elasticsearch.indices.percolate.total`
 * `elasticsearch.indices.refresh.total`
 * `elasticsearch.indices.refresh.total_time_in_millis`
 * `elasticsearch.indices.search.fetch_current`
 * `elasticsearch.indices.search.fetch_time_in_millis`
 * `elasticsearch.indices.search.fetch_total`
 * `elasticsearch.indices.search.open_contexts`
 * `elasticsearch.indices.search.query_current`
 * `elasticsearch.indices.search.query_time_in_millis`
 * `elasticsearch.indices.search.query_total`
 * `elasticsearch.indices.segments.count`
 * `elasticsearch.indices.segments.memory_in_bytes`
 * `elasticsearch.indices.store.size_in_bytes`
 * `elasticsearch.indices.store.throttle_time_in_millis`
 * `elasticsearch.indices.suggest.current`
 * `elasticsearch.indices.suggest.time_in_millis`
 * `elasticsearch.indices.suggest.total`
 * `elasticsearch.indices.translog.operations`
 * `elasticsearch.indices.translog.size_in_bytes`
 * `elasticsearch.indices.warmer.current`
 * `elasticsearch.indices.warmer.total`
 * `elasticsearch.indices.warmer.total_time_in_millis`
 * `elasticsearch.jvm.gc.collectors.old.collection_count`
 * `elasticsearch.jvm.gc.collectors.old.collection_time_in_millis`
 * `elasticsearch.jvm.gc.collectors.young.collection_count`
 * `elasticsearch.jvm.gc.collectors.young.collection_time_in_millis`
 * `elasticsearch.jvm.mem.heap_committed_in_bytes`
 * `elasticsearch.jvm.mem.heap_max_in_bytes`
 * `elasticsearch.jvm.mem.heap_used_in_bytes`
 * `elasticsearch.jvm.mem.heap_used_percent`
 * `elasticsearch.jvm.mem.non_heap_committed_in_bytes`
 * `elasticsearch.jvm.mem.non_heap_used_in_bytes`
 * `elasticsearch.jvm.threads.count`
 * `elasticsearch.jvm.threads.peak_count`
 * `elasticsearch.jvm.uptime_in_millis`
 * `elasticsearch.process.cpu.percent`
 * `elasticsearch.process.cpu.sys_in_millis`
 * `elasticsearch.process.cpu.total_in_millis`
 * `elasticsearch.process.cpu.user_in_millis`
 * `elasticsearch.process.mem.resident_in_bytes`
 * `elasticsearch.process.mem.share_in_bytes`
 * `elasticsearch.process.mem.total_virtual_in_bytes`
 * `elasticsearch.process.open_file_descriptors`
 * `elasticsearch.transport.rx_count`
 * `elasticsearch.transport.rx_size_in_bytes`
 * `elasticsearch.transport.server_open`
 * `elasticsearch.transport.tx_count`
 * `elasticsearch.transport.tx_size_in_bytes`


 [1]: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html
