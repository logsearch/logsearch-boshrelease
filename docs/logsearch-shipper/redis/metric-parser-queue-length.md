---
title: "Parser Queue Length"
---

We monitor how many log messages are waiting to be parsed.

Metric Name: `logstash.queue_size`


## Expectation

On a healthy system the queue length should typically be 0. Due to the timing of measurements, there will be occasional
spikes greater than 0 however they should be rare and should not happen for several, consecutive measurements.

The metric is ... when the trend is ...

 * **Healthy** - consistently 0
 * **Unhealthy** - consistently more than 0 (increasing or level)
 * **Recovering** - consistently decreasing


### Threshold

When defining an alerting threshold, you should take the following factors into consideration...

 * average number of messages your deployment receives per minute (`avg_msg_min`, count)
 * maximum number of time you're willing to allow real-time parsing to lag (`max_delay_sec`, seconds)
 * average size of your log messages; typically 1k is a generous size (`avg_msg_bytes`, bytes)
 * available RAM for the queue process (`queue_ram_bytes`, bytes)
 * available disk space for the queue process (`queue_disk_bytes`, bytes)
 * maximum time you want to allocate to resolve the issue (`resolve_min`, minutes)

@todo formalize equation or at least explain what the effects of higher/lower values are


## Cause

There may not be enough parsers running for the required load (whether a short-term spike or general underprovisioning).

 * [Review the archiver load](../answer/finding-an-optimal-number-of-archivers.md)

Components further down the pipeline may be failing (e.g. parsers, elasticsearch).

 * fix1 - dashboard of services running where

There may be a surge of log events from some source.

 * fix1 - create dashboard of @sources, @types?


## Effect

If the queue length continues increasing without being resolved, several things may directly happen...

Since messages aren't being parsed in a timely fashion, data will begin to visibly lag in dashboards and reports. End
users will become frustrated and confused.

With more queued data, the queue will run out of disk or memory. When it runs out of memory, the process crashes and
will end up continuously restarting while it tries (and fails) to restore the queue from disk. When it runs out of disk
space, the process may continue to run but it becomes very fragile because any sort of crash will result in data loss.

 * [Recover a failed queue](../../guides/recovering-a-failed-redis-queue.md)
