# logsearch

A scalable stack of [Elasticsearch](http://www.elasticsearch.org/overview/elasticsearch/),
[Logstash](http://www.elasticsearch.org/overview/logstash/), and
[Kibana](http://www.elasticsearch.org/overview/kibana/) for your
own [BOSH](http://docs.cloudfoundry.org/bosh/)-managed infrastructure.

 * Multiple Protocols - to receive logs via syslog (+TLS), relp, or lumberjack
 * Queue - to buffer against surges of log messages
 * Custom Parsing - to extract the fields from your own application-specific
   log format via logstash filters
 * Search - to find, aggregate, and report on those fields via elasticsearch
 * Visualize - to create and share dashboards of your logs via kibana
 * Archive - to retain log messages compressed and offsite in long-term storage
   via Amazon S3 or SFTP


## Getting Started

Upload the latest logsearch release from [bosh.io](https://bosh.io)...

    $ bosh upload release https://bosh.io/d/github.com/logsearch/logsearch-boshrelease

If you are using [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can
get started with our sample manifest, [`bosh-lite.yml`](./templates/bosh-lite.yml)...

    $ bosh -d templates/bosh-lite.yml deploy

For more details, review the [`docs/`](http://www.logsearch.io/docs/boshrelease/)
or raise an issue if you run into a bug.


## Testing

To run a sanity test which ships some sample logs, parses, and then queries them,
use the pre-configured `test_e2e_errand` errand from `templates/bosh-lite.yml`...

    $ bosh -d templates/bosh-lite.yml run errand test_e2e_errand
    ...snip...
    ==> Validating results...
    SUCCESS

To run tests for [logsearch-shipper](https://github.com/logsearch/logsearch-shipper-boshrelease)
integration, run the included script...

    $ ./bin/logsearch-shipper-config-buildtest
    ...snip...
    SUCCESS


## License

[Apache License 2.0](./LICENSE)
