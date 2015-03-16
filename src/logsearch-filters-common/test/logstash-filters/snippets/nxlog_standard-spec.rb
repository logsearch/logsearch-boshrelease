# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/grok"
require "json"

describe LogStash::Filters::Grok do

  describe "nxlog_standard" do

    config <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/syslog_standard.conf")}
        #{File.read("src/logstash-filters/snippets/nxlog_standard.conf")}
      }
    CONFIG

    sample("@message" => '<13>1 2014-06-23T09:54:13.275897+01:00 SHIPPER-HOSTNAME - - - [NXLOG@14506 EventReceivedTime="2014-06-23 09:54:13" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log" host="SOURCE-HOSTNAME" service="TradingAPI_IIS" type="iis_tradingapi"] 2014-06-23 08:53:46 W3SVC1 SOURCE-HOSTNAME 172.16.68.7 GET /tradingapi - 81 - 172.16.68.245 HTTP/1.0 - - - dns.name.co.uk 200 0 0 2923 106 46') do
      insist { subject["@type"] } == "iis_tradingapi"
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("2014-06-23T08:54:13.275Z")

      insist { subject['@message'] } == "2014-06-23 08:53:46 W3SVC1 SOURCE-HOSTNAME 172.16.68.7 GET /tradingapi - 81 - 172.16.68.245 HTTP/1.0 - - - dns.name.co.uk 200 0 0 2923 106 46"
      insist { subject['@shipper'] } == {
        "host" => "SHIPPER-HOSTNAME",
        "event_received_time" => "2014-06-23 09:54:13",
        "module_name" => "in1",
        "module_type" => "im_file"
      }
      insist { subject['@source'] } == {
        "path" => "\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log",
        "host" => "SOURCE-HOSTNAME",
        "service" => "TradingAPI_IIS"
      }
    end
  end

  describe "NXLOG parser doesn't gobble part of the message" do

    config <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/syslog_standard.conf")}
        #{File.read("src/logstash-filters/snippets/nxlog_standard.conf")}
      }
    CONFIG

    nxlog_syslog_prefix = '<13>1 2014-06-23T09:54:13.275897+01:00 SHIPPER-HOSTNAME - - - ' \
                        + '[NXLOG@14506 EventReceivedTime="2014-06-23 09:54:13" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\IIS\\W3SVC1\\u_ex140623.log" host="SOURCE-HOSTNAME" service="SOURCE_SERVICE" type="SOURCE_HOST"]'

    sample("@message" => "#{nxlog_syslog_prefix} 14:17:23.012 [RingBufferThread - default.priceMarket.impl.MTMarketPricing:0] INFO  S.C.Micros.PostThrottlePublication - (tupleid=0,count=3,avg=795,max=1838)") do
      insist { subject['@message'] } == "14:17:23.012 [RingBufferThread - default.priceMarket.impl.MTMarketPricing:0] INFO  S.C.Micros.PostThrottlePublication - (tupleid=0,count=3,avg=795,max=1838)"  
    end

    sample("@message" => "#{nxlog_syslog_prefix} INFO  2014-06-26 14:12:09,582 34 ObjectPooling.Pool`1+IItemStore[[ActiveMQPubSub.ActiveMQConnectionPool.IActiveMQPooledConnection, ActiveMQPubSub, Version=1.49.0.0, Culture=neutral, PublicKeyToken=null]] Number of pooled objects in use 1") do
      insist { subject['@message'] } == "INFO  2014-06-26 14:12:09,582 34 ObjectPooling.Pool`1+IItemStore[[ActiveMQPubSub.ActiveMQConnectionPool.IActiveMQPooledConnection, ActiveMQPubSub, Version=1.49.0.0, Culture=neutral, PublicKeyToken=null]] Number of pooled objects in use 1"  
    end
  end

end
