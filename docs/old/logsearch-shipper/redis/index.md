---
title: "Redis"
---

## Metrics


### Queue Lengths

 * [Archiver Queue Length](./metric-archiver-queue-length.md)
 * [Parser Queue Length](./metric-parser-queue-length.md)


### Internal Process Statistics

The following are forwarded from the internal redis metrics. See the [official Redis documentation][1] for details
about their meanings.

 * `redis.blocked_clients`
 * `redis.connected_clients`
 * `redis.connected_slaves`
 * `redis.evicted_keys`
 * `redis.total_commands_processed`
 * `redis.total_connections_received`
 * `redis.uptime_in_seconds`
 * `redis.used_memory`


 [1]: http://redis.io/commands/info
