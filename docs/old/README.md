---
title: "logsearch-boshrelease"
---

This documentation discusses many of the aspects of the [logsearch-boshrelease][1] project. Our focus here is to make
sure everyone on the team has shared knowledge about the architecture and management of logsearch deployments.


## Getting Started

 * [Understanding the Components](./getting-started/understanding-the-components.md)
 * [Deploying Logsearch](./getting-started/deploying-logsearch.md)
 * [Shipping Some Logs](./getting-started/shipping-some-logs.md)
 * [Customizing Log Parsing](./getting-started/customizing-log-parsing.md)
 * [Creating Kibana Dashboards](./getting-started/creating-kibana-dashboards.md)


## Guides

 * Architecture
    * At Scale
       * [Field Conventions for Log Events](./guides/field-conventions-for-log-events.md)
       * [Maintaining Log Parser Configurations](./guides/maintaining-log-parser-configurations.md)
       * [Using Logsearch Event Metadata](./guides/using-logsearch-event-metadata.md)
       * [Finding an Optimal Number of Parsers](./guides/finding-an-optimal-number-of-parsers.md)
    * Miscellaneous
       * [Logsearch Pipeline Dashboard](./dashboards/logsearch-pipeline.md)
 * Job-specific
    * elasticsearch
       * [Performing a Rolling Restart of Elasticsearch](./guides/performing-a-rolling-restart-of-elasticsearch.md)
       * [Checking Elasticsearch's Health](./guides/checking-elasticsearchs-health.md)
       * [Handling Missing Elasticsearch Shards](./guides/handling-missing-elasticsearch-shards.md)
    * queue
       * [Recovering a Failed Redis Queue](./guides/recovering-a-failed-redis-queue.md)
 * Development
    * [Creating a New Release](./guides/creating-a-new-release.md)
 * More Resources
    * [Log Shippers](./resources/log-shippers.md)
 * Debugging
    * [Debugging logs not being indexed](./guides/debugging-logs-not-being-indexed.md)

## Monitoring

We use [logsearch-shipper][2] to forward our deployment's logs and metrics to our own meta-logsearch cluster. Several
jobs annotate their logs and send custom metrics:

 * [elasticsearch](./logsearch-shipper/elasticsearch/)
 * [redis](./logsearch-shipper/redis/) 

In addition to watching standard host metrics (e.g. CPU, disk), you may also want to keep an eye on:

 * rate of logs being shipped from each service/file (to discover unexpected partitions or crashes)
 * number of `grokparsefailure`s (to discover unexpected formats)
 * number of mappings (to discover unbounded field parsing)


 [1]: https://github.com/logsearch/logsearch-boshrelease
 [2]: https://github.com/logsearch/logsearch-shipper-boshrelease
