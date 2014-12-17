---
title: "Shipping Logs"
---

Here are a few different methods that we have experience with in shipping logs.


## nxlog

We've found [nxlog][1] to be a powerful, multi-platform solution for many of our needs. Assuming you have configured and
deployed the `ingestor_syslog` job, you could start sending, for example, your `/var/sys/syslog` file into logsearch
with an nxlog configuration file like the following...

    @todo

We have successfully used nxlog on Windows and Linux machines.


## logsearch-shipper (BOSH Release)

If you want to start forwarding logs from existing BOSH deployments, you may be interested in our
[`logsearch-shipper`][3] BOSH release. It is intended to be deployed alongside your existing jobs and will, by default,
automatically forward all the `/var/vcap/sys/log` files, tagging them with the deployment and job identifiers. Visit the
[project page][4] to learn more about customizing logs with fields or shipping metrics.

The logsearch BOSH release itself uses the logsearch-shipper conventions to provide additional log details (e.g. some
predefined log types) and deployment metrics (e.g. queue size, search lag). This means you could deploy the
logsearch-shipper to your logsearch deployment in order to forward logs/metrics about it to another logsearch cluster.


## logstash-forwarder

Originally we started using [logstash-forwarder][2] (pre-Go rewrite) and ran into stability problems with large numbers
of files and hanging on instable network connections. Although we still have the `ingestor_lumberjack` job, we haven't
returned to logstash-forwarder since having success with nxlog.


 [1]: http://nxlog-ce.sourceforge.net/
 [2]: https://github.com/elasticsearch/logstash-forwarder
 [3]: https://github.com/logsearch/logsearch-shipper-boshrelease
