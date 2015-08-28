In addition to the changes below, we're starting to switch to semantic versioning (i.e. [semver][0] conventions and `23.0.0` instead `22`). We're also starting to publish dev releases via CI from our `develop` branch if you prefer testing recent changes before we create final releases (see [readme][3]).

Breaking Changes:

 * ingestors no longer support SSLv3 (dropped upstream by logstash)

Upgrades:

 * logstash 1.5.4 (from 1.5.2; #172)

Enhancements:

 * new [curator job][1] to regularly remove indices older than a configurable period (#72, via #170)
 * new [`logstash_parser.inputs` property][2] to configure parsers with non-redis inputs (via #160)
 * avoid extracting `syslog_procid`, `syslog_msgid` when they are empty (#138, via #175)

Development:

 * spiff templates now use separate queue and parser resource pools (via #169)
 * updated Concourse pipelines for more reliable CI testing, ability to test pull requests, and release automation (via #174)


 [0]: http://semver.org/
 [1]: https://github.com/logsearch/logsearch-boshrelease/blob/v23.0.0/jobs/curator/spec
 [2]: https://github.com/logsearch/logsearch-boshrelease/blob/v23.0.0/jobs/parser/spec#L36-L46
 [3]: https://github.com/logsearch/logsearch-boshrelease/tree/v23.0.0#release-channels
