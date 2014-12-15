---
title: "Customizing Log Parsing"
---

Logsearch provides the `log_parser.filters` property to allow you to customize how your messages are extracted. The
value can be any of logstash's filter directives, fully explained in [their documentation][1]. If you're not already
familiar with how logstash filters work, please read through their documentation first.

Continuing with the Mac OS X example of `/var/log/system.log`, we can customize logsearch so it's parsing out the
date/time, hostname, process name, process ID, and message from the following type of message...

    Dec 11 13:18:06 mymacbookpro Google Chrome Helper[920]: CoreText CopyFontsForRequest received mig IPC error (FFFFFFFFFFFFFECC) from font server

To extract the different fields in this message, we can use the `grok` filter...

    grok {
      match => [ "@message" , "%{SYSLOGTIMESTAMP:timestamp} %{HOSTNAME:hostname} (?<process_name>[^\[]+)\[%{INT:process_id:int}\]: %{GREEDYDATA:message}" ]
    }

Which will give us an event which looks like the following. As a convention, logsearch maintains `@message` as the raw
log message that it originally received.

    {
        "@message" : "Dec 11 13:18:06 mymacbookpro Google Chrome Helper[920]: CoreText CopyFontsForRequest received mig IPC error (FFFFFFFFFFFFFECC) from font server"
        "timestamp" : "Dec 11 13:18:06",
        "hostname" : "mymacbookpro",
        "process_name" : "Google Chrome Helper",
        "process_id" : 920,
        "message" : "CoreText CopyFontsForRequest received mig IPC error (FFFFFFFFFFFFFECC) from font server"
    }

The `@timestamp` field is another special field and represents when the log message happened. If no `date` filter is
used to extract one from the log message, the `@timestamp` will default to when the message was received by the
ingestor. It's always wise to use this since there may be delays between when the message is logged and when it reaches
the logsearch deployment.

    date {
        match => [ "timestamp" , "MMM dd HH:mm:ss" ]
        timezone => "America/Denver"
    }

After the `date` filter, our event will have an extra `@timestamp` key with a value like `2014-12-11T20:18:06+00:00`. To
apply these filters and get our parsers using them, we'll need to update the property in our deployment manifest...

    properties:
      log_parser:
        filters: |
          grok {
            match => [ "@message" , "%{SYSLOGTIMESTAMP:timestamp} %{HOSTNAME:hostname} (?<process_name>[^\[]+)\[%{INT:process_id:int}\]: %{GREEDYDATA:message}" ]
          }

          date {
            match => [ "timestamp" , "MMM dd HH:mm:ss" ]
            timezone => "America/Denver"
          }

After saving, we can run the deploy...

    $ bosh -d bosh-lite.yml deploy

Assuming you left the `tail ... | ./logstash-forwarder ...` process running in the background, the new fields should be
visible on new log messages once the parsers finish restarting with the new configuration. Now in Kibana you can search
for messages coming from a specific process. For example, you can enter `process_name:"Google Chrome Helper"` into the
Query field at the top of the page to see only Google Chrome Helper errors.

Typically you'll have many different log formats being pushed into your logsearch stack. After you move on from this
Getting Started example, you'll probably start utilizing logstash conditionals to only apply certain filter sets to
specifically matched rules. For example...

    if @source.path == '/var/vcap/jobs/elasticsearch/requests.log' {
        # apply rules to parse elasticsearch's requests log format
    }


---

**Next Topic**:  
[Creating Kibana Dashboards](./creating-kibana-dashboards.md)

Advanced Topics:  
[Maintaining Log Parser Configurations](../guides/maintaining-log-parser-configurations.md)


 [1]: http://logstash.net/docs/1.4.2/
