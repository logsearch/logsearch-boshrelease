---
title: "Using Logsearch Event Metadata"
---

Logsearch has a feature flag to include additional event metadata at each step of the message lifecycle. Since this adds
a notable number of fields and marginal disk/CPU overhead, this is disabled by default. The primary use of this is to
help when tuning the architecture and identifying bottlenecks.

To enable the event metadata, use the `logstash.metadata_level` and set it to `DEBUG`:

    properties:
      logstash:
        metadata_level: "DEBUG"

To disable it again, simply remove the property or set it to `NONE`:

    properties:
      logstash:
        metadata_level: "NONE"


## Fields

Once enabled, you'll find the following additional metadata fields available on each log message:

 * `@ingestor[timestamp]` - the time the ingestor saw the event (e.g. 2014-11-14T12:02:36.181Z)
 * `@ingestor[job]` - the job which ingested the event (e.g. ingestor/1)
 * `@ingestor[service]` - which logsearch job template received the message (e.g. syslog)
 * `@parser[timestamp]` - the time the parser saw the event (e.g. 2014-11-14T12:02:36.450Z)
 * `@parser[job]` - the job which parsed the event (e.g parser-z1/3)
 * `@parser[duration]` - the duration the parser took (e.g. 12; in ms)
 * `@timer[ingested_to_parsed]` - essentially the time our logsearch stack spent on the event from when we first saw it
   to (roughly) when the end user should be able to search it (e.g. 281; in ms)
 * `@timer[emit_to_ingested]`, `@timer[emit_to_parsed]` - if the conventional @timestamp field is parsed out of the log
   message, we can use that as an absolute starting point and get further insight into how slow shippers are to send the
   message (e.g. 301, 582; in ms)


## Usage

A few more details and some examples on how we've found the fields useful...


### Timestamps

The `@ingestor` and `@parser` timestamps identify when the message hit the two critical parts of the logsearch stack.
Once parsed, you should also have the standard logstash `@timestamp` field showing when the event was logged. If you're
trying to diagnose a particular message, you'll be able to confidently know where delays were coming from - whether it
was delayed because the log shipper took it's time or the message spent too much time in the logsearch queue.

Individually looking at messages isn't useful to trending, so the `@timer` fields provide you with graphable metrics
between the three shipper/ingestor/parser steps. Graph these values to identify trends.

As an example, you could graph `@timer[ingested_to_parsed]` over a few days. If you notice it's consistently higher
during the day, your parsers may be struggling to keep up with higher daytime loads.


### Jobs

The `@ingestor` and `@parser` job fields let you know which particular host was responsible for handling the event. If
you're running separate ingestors for different log shippers it makes it easier to verify where events are coming
through.

As an example, if you needed to improve parser performance, you could utilize a couple different instance types and
watch how their throughput compares. Or, try them in separate availability zones and see how latency affects timers,
too.


### Parser Duration

The `@parser[duration]` field makes it trivial to identify events which are taking a significant time to parse (since
slow parses affect the process' throughput but also adds load to all other parsers).

As an example, you could regularly look for events taking longer than 250ms in order to identify why they're taking so
long and make sure regular expressions and external lookups are behaving sanely.


## Dashboard

We created a dashboard to help us visualize some of this metadata and make metric-based decisions.
[Learn more](../dashboards/logsearch-pipeline.md) about how we use it.
