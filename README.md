# BOSH Release for logsearch

An easily-deployable stack of [Elasticsearch](http://www.elasticsearch.org/overview/elasticsearch/),
[Logstash](http://www.elasticsearch.org/overview/logstash/), and
[Kibana](http://www.elasticsearch.org/overview/kibana/) which can scale on your
own [BOSH](http://docs.cloudfoundry.org/bosh/)-managed infrastructure.


## Getting Started

First make sure you have properly targeted your existing BOSH director. Then
you can upload the latest logsearch release...

    git clone https://github.com/logsearch/logsearch-boshrelease.git
    cd logsearch-boshrelease
    bosh upload release releases/logsearch-latest.yml

Next you'll need to create your own deployment manifest. Right now the easiest
way to do that is by using one of the [`examples`](./examples) as a starting
point.

Then you can run the deploy...

    bosh deployment my_manifest.yml
    bosh deploy


### Shipping Logs

Logsearch can currently receive logs over three different protocols:

 * [Syslog, Syslog TLS](./jobs/ingestor_syslog/spec),
 * [RELP](./jobs/ingestor_relp/spec), and
 * [Lumberjack](./jobs/ingestor_lumberjack/spec).

Depending on the protocol, you may need to configure additional properties in
your deployment manifest (e.g. add certificates for Syslog TLS and Lumberjack).

If you need help getting your logs into the logsearch stack, you may find these
tools useful:

 * [nxlog](http://nxlog.org/) - multi-platform log collector and forwarder
 * [rsyslog](http://www.rsyslog.com/) - log collector and forwarder
 * [logstash-forwarder](https://github.com/elasticsearch/logstash-forwarder) - log forwarder (using lumberjack)


### Customizing Filters

By default, [some filters](https://github.com/logsearch/logsearch-boshrelease/blob/develop/jobs/log_parser/templates/config/filters_default.conf)
are pre-installed for common log formats, but eventually, you'll want to change
them or add your own application-specific log formats. Take a look at the
[`logsearch/logsearch-filters-common`](https://github.com/logsearch/logsearch-filters-common)
repository for [instructions](https://github.com/logsearch/logsearch-filters-common#reuse)
on setting up an environment for writing and testing your filters. Once written,
include your filters through the `logstash_parser.filters` property.


## Testing

```
RESTCLIENT_LOG=stdout API_URL="http://10.244.2.2" INGESTOR_HOST="10.244.2.14" bundle exec rspec
```

## License

[Apache License 2.0](./LICENSE)
