# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do

  describe 'Filters behave when combined' do

    config <<-CONFIG
      filter {
        #{File.read('target/logstash-filters-default.conf')}
      }
    CONFIG

    sample("@type" => "syslog", "@message" => '<13>1 2014-06-23T10:54:42.275897+01:00 SHIPPER-HOSTNAME - - - [NXLOG@14506 EventReceivedTime="2014-06-23 09:54:42" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\my-json-log.log" host="SOURCE-HOSTNAME" service="MyService" type="json"] {"level":"WARN","timestamp":"2014-02-04T23:45:12.000Z","logger":"I.am.a.JSON.logger","method":"testMe","message":"plain message accepted here."}') do
      insist { subject['tags'] } == [ 'syslog_standard' ]
      #@timestamp is the timestamp of the syslog message (although this might get overridden by future filters)
      insist { subject['@timestamp'] } == Time.iso8601('2014-06-23T09:54:42.275Z')

      #The @type has been set to the internal message type with the unparsed data in @message_unparsed, ready for further processing by other filters
      insist { subject['@type'] } === 'json'
      insist { subject['@message_unparsed'] } === '{"level":"WARN","timestamp":"2014-02-04T23:45:12.000Z","logger":"I.am.a.JSON.logger","method":"testMe","message":"plain message accepted here."}'

      # The @message should have remained untouched
      insist { subject['@message'] } == '<13>1 2014-06-23T10:54:42.275897+01:00 SHIPPER-HOSTNAME - - - [NXLOG@14506 EventReceivedTime="2014-06-23 09:54:42" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\my-json-log.log" host="SOURCE-HOSTNAME" service="MyService" type="json"] {"level":"WARN","timestamp":"2014-02-04T23:45:12.000Z","logger":"I.am.a.JSON.logger","method":"testMe","message":"plain message accepted here."}'
    end

  end

end
