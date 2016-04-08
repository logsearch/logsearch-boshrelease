# encoding: utf-8
require 'test/filter_test_helpers'

describe "BOSH NATS healthcheck log parsing rules" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/bosh_nats.conf")}
      }
    CONFIG
  end

  describe "hm_agent_heartbeat logs" do
    when_parsing_log(
      '@type' => 'syslog',
		  'syslog_program' => 'nats-to-syslog',
      '@message' => '{"Data":"{\"job\":\"router-partition-7c53ed3ae2e7f5543b91\",\"index\":0,\"job_state\":\"running\",\"vitals\":{\"cpu\":{\"sys\":\"0.0\",\"user\":\"0.1\",\"wait\":\"0.1\"},\"disk\":{\"ephemeral\":{\"inode_percent\":\"2.0\",\"percent\":\"5.0\"},\"persistent\":{\"inode_percent\":\"44.0\",\"percent\":\"54.0\"}, \"system\":{\"inode_percent\":\"37.0\",\"percent\":\"46.0\"}},\"load\":[\"0.00\",\"0.02\",\"0.05\"],\"mem\":{\"kb\":\"81812.0\",\"percent\":\"8.0\"},\"swap\":{\"kb\":\"0.0\",\"percent\":\"0.0\"}},\"node_id\":\"\"}","Reply":"","Subject":"hm.agent.heartbeat.192dc853-4f1a-4198-8844-d0ab8d7c2c8e"}'
    ) do

      it "adds bosh nats tag" do
        expect(subject["tags"]).to include "NATS"
      end

      it "adds the HM heartbeat tag" do
        expect(subject["tags"]).to include "hm_agent_heartbeat"
      end

      it "adds INFO log level" do
        expect(subject["@level"]).to eq "INFO"
      end

      it "sets @source.job" do
        expect(subject["@source"]["job"]).to eq "router-partition-7c53ed3ae2e7f5543b91"
      end

      it "sets @source.index" do
        expect(subject["@source"]["index"]).to eq 0
      end

      it "sets @source.vm" do
        expect(subject["@source"]["vm"]).to eq "router-partition-7c53ed3ae2e7f5543b91/0"
      end


      it "parses NATS.Subject" do
        expect(subject["NATS"]["Subject"]).to eq "hm.agent.heartbeat.192dc853-4f1a-4198-8844-d0ab8d7c2c8e"
      end

      it "parses NATS.Reply" do
        expect(subject["NATS"]["Reply"]).to eq ""
      end

      it "parses NATS.Data" do
        expect(subject["NATS"]["Data"]["job_state"]).to eq "running"
      end

      it "parses CPU stats" do
        expect(subject["NATS"]["Data"]["vitals"]["cpu"]).to eq(
          {
            "sys" => 0.0,
            "user" => 0.1,
            "wait" => 0.1
          }
        )
      end

      it "parses disk usage stats" do
        expect(subject["NATS"]["Data"]["vitals"]["disk"]).to eq(
          {
            "ephemeral" => {
              "inode_percent" => 2.0,
              "percent" => 5.0
            },
            "system" => {
              "inode_percent" => 37.0,
              "percent" => 46.0
            },
            "persistent" => {
              "inode_percent" => 44.0,
              "percent" => 54.0
            }
          }
        )
      end

      it "parses os load" do
        expect(subject["NATS"]["Data"]["vitals"]["load"]).to eq(
          {
            "avg01" => 0.0,
            "avg05" => 0.02,
            "avg15" => 0.05
          }
        )
      end

      it "parses memory usage stats" do
        expect(subject["NATS"]["Data"]["vitals"]["mem"]).to eq(
          {
            "kb" => 81812.0,
            "percent" => 8.0
          }
        )
      end

      it "parses swap usage stats" do
        expect(subject["NATS"]["Data"]["vitals"]["swap"]).to eq(
          {
            "kb" => 0.0,
            "percent" => 0.0
          }
        )
      end

      it "removes @message" do
        expect(subject["@message"]).to be_nil
      end
    end
  end

  describe "hm_alerts" do
    when_parsing_log(
      '@type' => 'syslog',
      'syslog_program' => 'nats-to-syslog',
      "@message" => '{"Data":"{\"id\":\"a053e70a-3689-48f4-79a9-0341a6e2f071\",\"severity\":4,\"title\":\"SSH Login\",\"summary\":\"Accepted publickey for vcap from 10.0.0.6 port 60528 ssh2: RSA df:e1:f7:e0:23:59:86:da:ef:a6:7f:5d:ac:68:49:83\",\"created_at\":1457022703}","Reply":"","Subject":"hm.agent.alert.bb2e7409-8fec-4715-b2d7-bad5a08efe88"}'
    ) do

      it "adds bosh nats tag" do
          expect(subject["tags"]).to include "NATS"
      end

      it "adds the HM alert" do
        expect(subject["tags"]).to include "hm_alert"
      end

      it "sets @level" do
        expect(subject["@level"]).to eq "WARN"
      end

      it "pares alert title" do
        expect(subject["NATS"]["Data"]["title"]).to eq "SSH Login"
      end

      it "parses alert summary" do
        expect(subject["NATS"]["Data"]["summary"]).to eq "Accepted publickey for vcap from 10.0.0.6 port 60528 ssh2: RSA df:e1:f7:e0:23:59:86:da:ef:a6:7f:5d:ac:68:49:83"
      end

      it "removes @message" do
        expect(subject["@message"]).to be_nil
      end
    end
  end # describe hm_alerts
end

