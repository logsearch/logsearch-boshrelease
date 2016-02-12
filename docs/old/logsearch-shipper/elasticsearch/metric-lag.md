---
title: "Search Lag"
---

We monitor how far away the most recent, searchable log message in elasticsearch is.

Metric Name: `logstash.search_lag`


## Expectation

On a healthy system this should typically be in the single digits (assuming logs are always flowing into the stack).
This threshold is subjective to your requirements.

The metric is ... when the trend is ...

 * **Healthy** - consistently <10
 * **Unhealthy** - consistently more than 10 (increasing or level)
 * **Recovering** - consistently decreasing


### Threshold

When defining an alerting threshold, you should take the following factors into consideration...

 * average number of messages your deployment receives per minute (`avg_msg_min`, count)
 * maximum number of time you're willing to allow real-time parsing to lag (`max_delay_sec`, seconds)

@todo formalize equation or at least explain what the effects of higher/lower values are


## Cause

The cluster may be unhealthy from missing nodes, disk bottlenecks, or slow indexing.

 * [Review the elasticsearch cluster health](../../guides/checking-elasticsearchs-health.md)

There may not be enough parsers running for the required load (whether a short-term spike or general underprovisioning).

 * [Review the parser load](../../guides/finding-an-optimal-number-of-parsers.md)

Components further up the pipeline may be failing (e.g. parsers, queue, ingestors).

 * fix1 - dashboard of services running where


## Effect

Since messages aren't appearing in a timely fashion, data will begin to visibly lag in dashboards and reports. End users
will become frustrated and confused.
