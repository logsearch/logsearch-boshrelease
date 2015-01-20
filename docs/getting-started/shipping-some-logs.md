---
title: "Shipping Some Logs"
---

A Logsearch cluster with no logs is sad.  Lets make the local test cluster you just deployed happy by shipping it some logs.

# Concepts

## Shipping

We call the act of getting logs into the Logsearch cluster shipping.  Logs can come from may places; but most often they are in the form of a log file on a server's disk.

In this guide we will be shipping some sample Nginx webserver logs from the www.logsearch.io website.

## Shipper

We call the piece of software that does the shipping of the log file a shipper.  This could be a general piece of software (such as [Logstash](http://www.elasticsearch.org/guide/en/logstash/current/index.html) or [nxlog](http://nxlog-ce.sourceforge.net/)) configured to tail a log file and send its contents to the Logsearch cluster, or a specialised lightweight piece of software that only does log tailing (like [Logstash-forwarder](https://github.com/elasticsearch/logstash-forwarder)).

In this guide we will be configuring the Logstash installed by default in the Logsearch Workspace to be the shipper.

## Ingestor

A Logsearch cluster has one (or many) ingestors, which listen for logs at a specific IP address / TCP/UDP port combo.

We configure which ingestors to run, and where they should listen in the Logsearch cluster manifest, eg:

    ...snip...
    jobs:
    - name: ingestor
      release: logsearch
      templates:
      - name: ingestor_syslog
      instances: 1
      resource_pool: warden
      networks:
      - name: warden
        static_ips:
        - 10.244.10.6
    ...snip...
    properties: 
      logstash_ingestor:
        syslog:
          port: 514
    ...snip...

The Logsearch cluster we have just deployed is configured to listen on 10.244.2.10:514 for syslog log events.

## Transport protocol

Log events are encoded in a transport protocol when sent `over the wire`. The transport protocol is often encrypted using SSL. 

In this guide we will be using the standard unencrypted [Syslog RFC5242](https://tools.ietf.org/html/rfc5424) protocol.

## Log parsing

A logsearch cluster needs to be deployed with a set of Log parsing rules that configure how the raw log data should be parsed and enriched before being indexed in Elasticsearch as key=>value pairs.

In this guide the Logsearch cluster has been deployed with the [Logsearch for Weblogs Addon](https://github.com/logsearch/logsearch-for-weblogs), so it knows how to parse standard Nginx access logs.

# Shipping some sample logs

A set of nginx weblogs for the www.logsearch.io website have been archived at `https://s3-eu-west-1.amazonaws.com/ci-logsearch/logs/logsearch.io/logsearch.io-nginx-access-20150119.log.tar.gz`

You can import them from inside your Logsearch Workspace using the `ship-logsearch.io-sample-data` script, ie:

     [logsearch workspace] ~/environments/local/test ▸ ./logsearch/logsearch-for-weblogs/bin/ship-logsearch.io-sample-data 
     ===> Loading test data ...
     Importing data from https://s3-eu-west-1.amazonaws.com/ci-logsearch/logs/logsearch.io/logsearch.io-nginx-access-20150119.log.tar.gz
     Using milestone 1 output plugin 'syslog'. This plugin should work, but would benefit from use by folks like you.  Please let us know if you find bugs or have suggestions on how to improve this plugin.  For more information on plugin milestones, see http://logstash.net/docs/1.4.0/plugin-milestones {:level=>:warn}
     Pipeline started {:level=>:info}
     2015-01-20T15:55:01.747+0000 logsearch-workspace 90.212.226.35 - - [19/Jan/2015:12:34:46 +0000] "GET      /javascript/anchorific.min.js HTTP/1.1" 200 2493 "http://www.logsearch.io/" "Mozilla/5.0 (Macintosh; Intel Mac OS X  10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" 0.000
     2015-01-20T15:55:01.747+0000 logsearch-workspace 90.212.226.35 - - [19/Jan/2015:12:34:47 +0000] "GET      /images/performance.png HTTP/1.1" 200 89509 "http://www.logsearch.io/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_
     
     ...snip...
     
     /docs/boshrelease/logsearch-shipper/answer/finding-an-optimal-number-of-archivers.html HTTP/1.1" 404 142 "http://www.     logsearch.io/docs/boshrelease/logsearch-shipper/redis/metric-parser-queue-length.html" "Wget/1.14 (darwin13.0.2)" 0.     000
     Plugin is finished {:plugin=><LogStash::Outputs::Stdout >, :level=>:info}
     Plugin is finished {:plugin=><LogStash::Outputs::Syslog host=>"10.244.10.6", protocol=>"udp", rfc=>"rfc5424",      facility=>"user-level", severity=>"informational", structured_data=>"@type=%{[@type]}", sourcehost=>"%{host}", timestamp=>"%{@timestamp}", appname=>"LOGSTASH", procid=>"-", msgid=>"-">, :level=>:info}
     Pipeline shutdown complete. {:level=>:info}
     [logsearch workspace] ~/environments/local/test ▸

Sample logs have passed through the log processing pipeline, and have been indexed in our local test elasticsearch cluster.

We can ask Elasticsearch for a list of its indexes to see that what data it has:

     [logsearch workspace] ~/environments/local/test ▸ curl 10.244.10.2:9200/_cat/indices?v
     health index               pri rep docs.count docs.deleted store.size pri.store.size 
     green  logstash-2015.01.20   4   1        375            0        1mb        504.1kb 

In the example above we can see that we have 375 Log event `docs` in an index names `logstash-2015.01.20`

#Analysing the logs

Now that we have some data in our test Logsearch cluster, we can start to analyse it.  We can do this programatically sending HTTP requests 
to the `api/0`.  

For example, we could search for (and fetch the first 2) occurences of the word `firefox` in the logs using:

     [logsearch workspace] ~ ▸ curl '10.244.10.2/logstash-2015.01.20/_search?q=firefox&size=2&pretty'
     {
       "took" : 7,
       "timed_out" : false,
       "_shards" : {
         "total" : 4,
         "successful" : 4,
         "failed" : 0
       },
       "hits" : {
         "total" : 16,
         "max_score" : 0.5501497,
         "hits" : [ {
           "_index" : "logstash-2015.01.20",
           "_type" : "nginx_combined",
           "_id" : "GUTJoJncRtKPFfofXkZl9Q",
           "_score" : 0.5501497,
           "_source":{"@version":"1","@timestamp":"2015-01-20T12:35:06.000Z","host":"10.0.2.15","@type":"nginx_combined","@message":"<14>1 2015-01-20T16:02:19.250+0000 logsearch-workspace LOGSTASH - - [LOGSTASH@1.4.0 @type=nginx_combined] 80.229.7.108 - - [20/Jan/2015:12:35:06 +0000] \"GET /javascript/main.js HTTP/1.1\" 304 0 \"http://www.logsearch.io/docs/boshrelease/getting-started/deploying-logsearch.html\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:35.0) Gecko/20100101 Firefox/35.0\" 0.000","syslog_pri":"14","syslog5424_ver":1,"syslog_program":"LOGSTASH","syslog_message":"80.229.7.108 - - [20/Jan/2015:12:35:06 +0000] \"GET /javascript/main.js HTTP/1.1\" 304 0 \"http://www.logsearch.io/docs/boshrelease/getting-started/deploying-logsearch.html\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:35.0) Gecko/20100101 Firefox/35.0\" 0.000","received_at":"2015-01-20 16:02:19 +0000","received_from":"10.0.2.15","tags":["syslog_standard","nginx"],"syslog_severity_code":6,"syslog_facility_code":1,"syslog_facility":"user-level","syslog_severity":"informational","@source.host":"logsearch-workspace","syslog_procid":"-","syslog_msgid":"-","syslog_sd_id":"LOGSTASH@1.4.0","syslog_sd_params":{},"remote_addr":"80.229.7.108","remote_user":"-","time_local":"20/Jan/2015:12:35:06 +0000","request_method":"GET","request_uri":"/javascript/main.js","request_httpversion":"1.1","status":304,"body_bytes_sent":0,"http_referer":"http://www.logsearch.io/docs/boshrelease/getting-started/deploying-logsearch.html","http_user_agent":"\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:35.0) Gecko/20100101 Firefox/35.0\"","request_time":0,"geoip":{"ip":"80.229.7.108","country_code2":"GB","country_code3":"GBR","country_name":"United Kingdom","continent_code":"EU","latitude":54.0,"longitude":-2.0,"timezone":"Europe/London","location":[-2.0,54.0]}}
         }, {
           "_index" : "logstash-2015.01.20",
           "_type" : "nginx_combined",
           "_id" : "QgFRZr_dSwCS3z3m7q3-vw",
           "_score" : 0.5501497,
           "_source":{"@version":"1","@timestamp":"2015-01-20T16:56:40.000Z","host":"10.0.2.15","@type":"nginx_combined","@message":"<14>1 2015-01-20T16:02:19.514+0000 logsearch-workspace LOGSTASH - - [LOGSTASH@1.4.0 @type=nginx_combined] 66.249.81.235 - - [20/Jan/2015:16:56:40 +0000] \"GET /favicon.ico HTTP/1.1\" 404 142 \"-\" \"Mozilla/5.0 (Windows NT 6.1; rv:6.0) Gecko/20110814 Firefox/6.0 Google favicon\" 0.000","syslog_pri":"14","syslog5424_ver":1,"syslog_program":"LOGSTASH","syslog_message":"66.249.81.235 - - [20/Jan/2015:16:56:40 +0000] \"GET /favicon.ico HTTP/1.1\" 404 142 \"-\" \"Mozilla/5.0 (Windows NT 6.1; rv:6.0) Gecko/20110814 Firefox/6.0 Google favicon\" 0.000","received_at":"2015-01-20 16:02:19 +0000","received_from":"10.0.2.15","tags":["syslog_standard","nginx"],"syslog_severity_code":6,"syslog_facility_code":1,"syslog_facility":"user-level","syslog_severity":"informational","@source.host":"logsearch-workspace","syslog_procid":"-","syslog_msgid":"-","syslog_sd_id":"LOGSTASH@1.4.0","syslog_sd_params":{},"remote_addr":"66.249.81.235","remote_user":"-","time_local":"20/Jan/2015:16:56:40 +0000","request_method":"GET","request_uri":"/favicon.ico","request_httpversion":"1.1","status":404,"body_bytes_sent":142,"http_user_agent":"\"Mozilla/5.0 (Windows NT 6.1; rv:6.0) Gecko/20110814 Firefox/6.0 Google favicon\"","request_time":0,"geoip":{"ip":"66.249.81.235","country_code2":"US","country_code3":"USA","country_name":"United States","continent_code":"NA","latitude":38.0,"longitude":-97.0,"dma_code":0,"area_code":0,"location":[-97.0,38.0]}}
         } ]
       }
     }

However, a much more intuitive and visual way to analyse the logs is using the Kibana webapp deployed with your Logsearch cluster.  

Under the covers this is issuing similar HTTP search queries; but then displaying the results in readable charts and tables.

---
**Next Topic**:  
[Creating Kibana Dashboards](./creating-kibana-dashboards.md)

Advanced Topics:  
[Customizing Log Parsing](./customizing-log-parsing.md)
[Log Shippers](../resources/log-shippers.md)


