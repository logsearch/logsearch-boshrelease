# encoding: utf-8
require "test/filter_test_helpers"

describe 'Logstash filters' do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read('target/logstash-filters-syslog-standard.conf')}
        #{File.read('target/logstash-filters-bosh-nats.conf')}
        #{File.read('target/logstash-filters-haproxy.conf')}
      }
    CONFIG
  end

  context "when parsing syslog RFC 5242 messages" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<13>1 2014-06-23T10:54:42.275897+01:00 SHIPPER-HOSTNAME - - - [NXLOG@14506 EventReceivedTime="2014-06-23 09:54:42" SourceModuleName="in1" SourceModuleType="im_file" path="\\\\SOURCE-HOSTNAME\\Logs\\my-json-log.log" host="SOURCE-HOSTNAME" service="MyService" type="json"] {"level":"WARN","timestamp":"2014-02-04T23:45:12.000Z","logger":"I.am.a.JSON.logger","method":"testMe","message":"plain message accepted here."}') do

        it "applies the syslog parsers successfully" do
          expect(subject['tags']).to eq [ 'syslog_standard' ]
        end
      end
  end

  context "when parsing haproxy log messages" do
    when_parsing_log(
      '@type' => "syslog",
      '@message' => "<46>Dec 16 15:24:05 haproxy[9252]: 52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 SC 8/8/8/0/3 0/0",
    ) do

      it "applies the haproxy parsers successfully" do
        expect(subject['tags']).to include("haproxy")
      end
    end

  end
end
