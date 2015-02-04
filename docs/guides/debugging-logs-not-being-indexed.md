---
title: "Debugging logs not being indexed"
---

Shipping in logs that then don't appear in your Kibana dashboard can be very frustrating.

The way to debug this is to follow the log step by step as it passes through the ingestion pipeline.

0. Start by shipping in a log file with a unique string in it, eg 'fgkjsdfb'

0. Find the raw log message in the tailing the queue (`bosh ssh queue/0`)

    tail --follow=name /var/vcap/store/queue/redis-appendonly.aof | grep fgkjsdfb

0. Add a test for it in our integration test, eg: `test/cityindex-spec.rb`
    
    sample('@message' => "<13>1 2015-02-04T21:36:39.424060+07:00 Andrei-PC - - - [NXLOG@14506 timestamp=\"2015-02-04 21:36:36\"     
    level=\"INFO\" nxlog_message=\"nxlog-ce-2.8.1248 started\" logger=\"nxlog.exe\" environment=\"Nxlog.Test\" TestField=\"fgkjsdfb\"     
    type=\"json\"] {\"timestamp\":\"2015-02-04 21:36:36\",\"level\":\"INFO\",\"nxlog_message\":\"nxlog-ce-2.8.1248     
    started\",\"logger\":\"nxlog.exe\",\"environment\":\"Nxlog.Test\",\"TestField\":\"fgkjsdfb\"}\r","@version"=>"1","@timestamp"=>"2015-02-    
    04T14:36:39.964Z","@type"=>"syslog","@ingestor.remote_host"=>"54.76.94.126:52772","@ingestor"=>{"service"=>"syslog","job"=>    
    "ingestor/0","timestamp"=>"2015-02-04T14:36:39.964+00:00"}) do
       insist { subject.to_hash }.nil?
     end

0. Assuming the parsed output looks correct looks correct, try manually putting it in the index, eg:

    cat | curl -XPOST -d '@-' api.meta.logsearch.io:9200/logstash-2015.02.04/json/testdoc1

Hopefully the reason for the log not being indexed will become clear as you work through these steps.