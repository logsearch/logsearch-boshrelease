Upgrades:

 * Elasticsearch 1.6.0 (from 1.5.2, via #141)
 * Logstash 1.5.2 (from 1.5.0, via #141)
 * Kibana 4.1.1 (from 4.0.1, via #141)

Bug Fixes:

 * Fixed redis logging to `/dev/null` (via #143)

Enhancements:

 * Switch elasticsearch and redis to run as vcap user (#116 via #133)
 * Messages without a type are indexed as `unknown` instead of `%{@type}` (#65 via #134)
 * Optional, ingestor-tier logstash filters support (#4 via #135)
 * Allow configuring elasticsearch templates and documents by deployment manifest (#40 via #144)
 * New job errand for executing a simple ship-parse-search lifecycle as a test (#132)
 * Switch to [logging conventions][1] from logsearch-shipper's release-utils

Other:

 * Improved spiff-managed, stub files for AWS and warden (via #137)
 * Concourse CI pipelines (WIP)

 [1]: https://github.com/logsearch/logsearch-shipper-boshrelease/blob/f7d066e60ad2e60c4dad78fd51e7af73fd036509/share/release-utils/README.md
