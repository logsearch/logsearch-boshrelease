Breaking Changes:

 * renamed `log_parser` job template to just `parser`
 * renamed `elasticsearch.config.*` properties to `elasticsearch_config.*`

Upgrades:

 * elasticsearch 1.7.1 (from 1.6.0; via #163)

Bug Fixes:

 * use monit dependencies to ensure local elasticsearch shuts down after logstash (#161)

Enhancements:

 * improved spiff templates for colocation and vsphere support (via #149, #150, #156, #157, #159)
 * disable redis snapshotting (#142)
 * update PID file used by kibana job (#145)

Development:

 * improved errand for testing (via #148, #152)
