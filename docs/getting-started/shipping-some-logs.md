---
title: "Shipping Some Logs"
---

Now that you have a logsearch deployment running (albeit a small one), you can start shipping some logs into it.
Whenever you are configuring a log shipper (regardless of deployment) there are a few important things you'll need to
know...

 * protocol - whether to ship via syslog, relp, lumberjack, etc
 * endpoint - which hostname/IP and port to point to
 * security - some ingestors will require a TLS key/certificate to be configured.

For this guide, we'll use the simplest method: ship with the lumberjack protocol to our ingestor at `10.244.2.14:5043`
with the TLS key that you can find in the example manifest. You can download logstash-forwarder from [gobuild.io][1] to
get started. On Mac OS X you could temporarily download it by running...

    $ mkdir /tmp/logstash-forwarder
    $ cd /tmp/logstash-forwarder
    $ curl -LO http://gobuild3.qiniudn.com/github.com/elasticsearch/logstash-forwarder/branch-v-master/logstash-forwarder-darwin-amd64.zip 
    $ unzip logstash-forwarder-darwin-amd64.zip 
    $ ./logstash-forwarder -h

Download the bosh-lite sample certificate and the configuration file...

    $ curl -s "https://raw.githubusercontent.com/logsearch/logsearch-boshrelease/develop/examples/certificates/ingestor-20241214a/ca.crt" \
      > logstash-forwarder-ca.crt
    $ curl -s "https://raw.githubusercontent.com/logsearch/logsearch-boshrelease/develop/examples/bosh-lite/logstash-forwarder.json" \
      > logstash-forwarder.json

The configuration file will attempt to forward `/var/log/system.log`, `/var/log/syslog`, and anything from `stdin`. If
those inputs are missing, you'll see a warning which you can ignore. On Mac OS X, you could forward
`/var/log/system.log` (by default) and `/var/log/authd.log` (via `stdin`) by running...

    $ tail -f /var/log/authd.log | ./logstash-forwarder -config logstash-forwarder.json

You can generate some events by opening Terminal windows or running some commands with `sudo`. After a few messages have
been sent, you can visualize them by opening Kibana on the `api/0` node:

    http://10.244.2.2/_plugin/kibana/#/dashboard/file/default.json

You should see a few recent bars on the right side of the top chart, as well as the raw log messages in the table below.
Since the parser doesn't really know what the format of these messages is, there's only a single, `@message` field with
the log message.


---

**Next Topic**:  
[Customizing Log Parsing](./customizing-log-parsing.md)

Advanced Topics:  
[Log Shippers](../resources/log-shippers.md)


 [1]: http://gobuild.io/github.com/elasticsearch/logstash-forwarder
 [2]: https://github.com/logsearch/logsearch-boshrelease/blob/develop/spec/smoke/bosh-lite.lumberjack.crt
 [3]: https://github.com/logsearch/logsearch-boshrelease/blob/develop/spec/smoke/stdin_to_bosh-lite.json
