# encoding: utf-8
require "test/filter_test_helpers"

describe 'Logstash filters' do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read('target/logstash-filters-default.conf')}
        #{File.read('src/logstash-filters/deployment.conf')}
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

  context "when parsing a logsearch cluster log message" do
    when_parsing_log(
      '@type' => "syslog",
      '@message' => '<6>2016-04-12T13:04:56Z b5841bbc-ee95-48a9-8b42-0e60f52d1c5e nats-to-syslog[22919]: {"Data":"{\"deployment\":\"cf-a1-jarvice\",\"job\":\"ingestor\",\"index\":0,\"job_state\":\"running\",\"vitals\":{\"cpu\":{\"sys\":\"0.1\",\"user\":\"0.4\",\"wait\":\"0.2\"},\"disk\":{\"ephemeral\":{\"inode_percent\":\"0\",\"percent\":\"2\"},\"system\":{\"inode_percent\":\"31\",\"percent\":\"39\"}},\"load\":[\"0.00\",\"0.01\",\"0.05\"],\"mem\":{\"kb\":\"77300\",\"percent\":\"2\"},\"swap\":{\"kb\":\"0\",\"percent\":\"0\"}},\"node_id\":\"\"}","Reply":"","Subject":"hm.agent.heartbeat.1a03d017-68f3-4333-b05d-53ab95a6f3a4"}',
    ) do

      it "applies the haproxy parsers successfully" do
        expect(subject['tags']).to include "auto_deployment"
      end

      it "sets @source.deployment" do
        expect(subject['@source']["deployment"]).to eq "logsearch"
      end
    end
  end
end
