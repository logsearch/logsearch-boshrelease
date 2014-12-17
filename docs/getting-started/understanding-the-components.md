---
title: "Understanding the Components"
---

## Software

At its core, logsearch is based on several open-source software components:

 * [BOSH][5] - handles the infrastructure and scaling aspects of the services
 * The "ELK" Stack
    * [elasticsearch][1] - indexes and stores all the log data
    * [logstash][2] - plays multiple roles from receiving, parsing, and archiving data
    * [kibana][3] - displays log data in meaningful charts and tables
 * [redis][4] - queues data to help buffer against spikes in log throughput


## Architectural

From an architectural side of things, there are a few different tiers mirroring the various stages log data hits
throughout its lifecycle.

    @todo graphic
    logs -> (shipper) -> (ingestor+) --> (parse queue) -> (parser+) -> (elasticsearch)
                                     \
                                      -> (archive queue) -> (archiver+) -> (s3)


### Logs

ima log message


### Shippers

Shippers are responsible for pushing log data into the logsearch cluster. Logsearch itself doesn't particularly care
what is shipping the data - that is, it doesn't matter whether an application is talking directly to the cluster or
whether an external process is tailing an existing log file and talking to the cluster). Logsearch is only concerned
with the protocols it's using. As such, use whatever log shipping solution works best for your environment.

 > We've used a [few different shippers](./shipping-logs.md), depending on the logging environment.

Shippers are configured to push their log data to one of your ingestor endpoints.


### Ingestors

The ingestion tier is responsible for receiving log data in whatever protocol your shippers are sending data in.
Logsearch currently supports several different protocols (all implemented using logstash): lumberjack, relp, and syslog.
Typically you'll run at least one ingestor job, installing only the protocols you use.

 > We primarily use syslog with TLS enabled.

As ingestors receive messages, they push them into the queue.


### Queue

Redis acts as a buffer by temporarily holding messages from ingestors in a queue. Sometimes, applications and systems
can have very erratic logging behavior. Rather than provisioning for peak throughput, the buffer allows you to provision
for, say, 95% peak and rely on the queue during high loads. During high loads, messages may be waiting in the queue for
a few seconds (or minutes) until a processor is ready for it.

The queue holds messages until the next step is ready to process them.


### Parsers

Parsers are responsible for pulling messages off the queue and transforming them into a searchable document. Logstash
uses user-configured filter rules to manipulate the message. The parsers are the most scalable component of logsearch;
i.e. you'll encounter bottlenecks with the redis queue or elasticsearch if you scale out too many parsers.

 > We typically run double the servers required by our average parsing load. This allows us to easily handle log spikes,
 > but it also lets us use AWS Spot Instances with minimal impact if an Availability Zone (or two) are highly contested.

Once messages are parsed, logstash pushes them into persistent storage.


### Log Storage

Elasticsearch is responsible for the efficient indexing, storage, and retrieval of log messages. It is extremely
powerful and is very adept at scaling out. Elasticsearch uses shards and replicas to help distribute search load and
ensure fault tolerance. As your deployment grows, you can take advantage of elasticsearch's advanced allocation settings
and operational modes.

 > We run a couple API elasticsearch nodes as "master-only" and several "data-only" elasticsearch nodes with data
 > replicated across multiple AWS Availability Zones.


### Visualization

Kibana provides a customizable, user-friendly way to visualize your log data.


### Archiving

Logsearch has optional archiving functionality which enables long-term storage of raw log messages entering the stack.
If enabled, in addition to pushing messages for parsing, ingestors will push a second copy of every log message into a
separate queue. The `ingestor_archiver` job needs to be deployed somewhere and becomes responsible for writing those
messages to disk and then regularly compressing and uploading them off-site.

 > We currently upload our archives to AWS S3 where our daily sizes average just over 1 GB for 50m messages.


---

**Next Topic**:  
[Deploying Logsearch](./deploying-logsearch.md)


 [1]: http://www.elasticsearch.org/overview/elasticsearch/
 [2]: http://www.elasticsearch.org/overview/logstash/
 [3]: http://www.elasticsearch.org/overview/kibana/
 [4]: http://redis.io/
 [5]: http://docs.cloudfoundry.org/bosh/
