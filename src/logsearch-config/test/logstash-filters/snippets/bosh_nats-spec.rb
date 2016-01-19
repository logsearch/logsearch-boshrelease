# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/grok"
require "awesome_print"

describe LogStash::Filters::Grok do

  config <<-CONFIG
    filter {
      #{File.read("target/logstash-filters-default.conf")}
    }
  CONFIG

  describe "Parse BOSH nats messages" do

    describe "hm_agent_heartbeat" do

      sample("@type" => "syslog", "@message" => '<6>2015-11-25T12:28:10Z a9ffd17a-ec13-48e9-6091-38664ceee810 nats-to-syslog[20322]: {"Data":"{\"job\":\"router-partition-7c53ed3ae2e7f5543b91\",\"index\":0,\"job_state\":\"running\",\"vitals\":{\"cpu\":{\"sys\":\"0.0\",\"user\":\"0.1\",\"wait\":\"0.1\"},\"disk\":{\"ephemeral\":{\"inode_percent\":\"2.0\",\"percent\":\"5.0\"},\"system\":{\"inode_percent\":\"37.0\",\"percent\":\"46.0\"}},\"load\":[\"0.00\",\"0.02\",\"0.05\"],\"mem\":{\"kb\":\"81812.0\",\"percent\":\"8.0\"},\"swap\":{\"kb\":\"0.0\",\"percent\":\"0.0\"}},\"node_id\":\"\"}","Reply":"","Subject":"hm.agent.heartbeat.192dc853-4f1a-4198-8844-d0ab8d7c2c8e"}') do

        insist { subject["tags"] } == ["syslog_standard", "NATS", "hm_agent_heartbeat"]
        insist { subject["@level"] } == "INFO"

        insist { subject["@source"]["deployment"] } == "CF"
        insist { subject["@source"]["name"] } == "router-partition-7c53ed3ae2e7f5543b91/0"
        insist { subject["@source"]["component"] } == "router-partition-7c53ed3ae2e7f5543b91"
        insist { subject["@source"]["instance"] } == 0

        insist { subject["NATS"]["Subject"] } == "hm.agent.heartbeat.192dc853-4f1a-4198-8844-d0ab8d7c2c8e"
        insist { subject["NATS"]["Reply"] } == ""

        insist { subject["NATS"]["Data"]["job_state"] } == "running"

        insist { subject["NATS"]["Data"]["vitals"] } == {
          "cpu" => {
                "sys" => 0.0,
                "user" => 0.1,
                "wait" => 0.1
          },
          "disk" => {
              "ephemeral" => {
              "inode_percent" => 2.0,
                    "percent" => 5.0
            },
              "system" => {
              "inode_percent" => 37.0,
              "percent" => 46.0
              }
          },
          "load" => {
              "avg01" => 0.0,
              "avg05" => 0.02,
              "avg15" => 0.05
          },
          "mem" => {
             "kb" => 81812.0,
              "percent" => 8.0
          },
          "swap" => {
             "kb" => 0.0,
              "percent" => 0.0
          }
        }

      end

      describe "should correctly extract persistent disk vitals" do
         sample("@type" => "syslog", "@message" => '<6>2015-11-25T12:28:10Z a9ffd17a-ec13-48e9-6091-38664ceee810 nats-to-syslog[20322]: {"Data":"{\"job\":\"router-partition-7c53ed3ae2e7f5543b91\",\"index\":0,\"job_state\":\"running\",\"vitals\":{\"cpu\":{\"sys\":\"0.0\",\"user\":\"0.1\",\"wait\":\"0.1\"},\"disk\":{\"ephemeral\":{\"inode_percent\":\"2.0\",\"percent\":\"5.0\"},\"persistent\":{\"inode_percent\":\"44.0\",\"percent\":\"54.0\"}, \"system\":{\"inode_percent\":\"37.0\",\"percent\":\"46.0\"}},\"load\":[\"0.00\",\"0.02\",\"0.05\"],\"mem\":{\"kb\":\"81812.0\",\"percent\":\"8.0\"},\"swap\":{\"kb\":\"0.0\",\"percent\":\"0.0\"}},\"node_id\":\"\"}","Reply":"","Subject":"hm.agent.heartbeat.192dc853-4f1a-4198-8844-d0ab8d7c2c8e"}') do


           insist { subject["NATS"]["Data"]["vitals"] } == {
             "cpu" => {
                   "sys" => 0.0,
                   "user" => 0.1,
                   "wait" => 0.1
             },
             "disk" => {
               "ephemeral" => {
                 "inode_percent" => 2.0,
                       "percent" => 5.0
               },
               "persistent" => {
                 "inode_percent" => 44.0,
                 "percent" => 54.0
                },
                "system" => {
                   "inode_percent" => 37.0,
                   "percent" => 46.0
                }
             },
             "load" => {
                 "avg01" => 0.0,
                 "avg05" => 0.02,
                 "avg15" => 0.05
             },
             "mem" => {
                "kb" => 81812.0,
                 "percent" => 8.0
             },
             "swap" => {
                "kb" => 0.0,
                 "percent" => 0.0
             }
           }

           end
        end # should correctly extract persistent disk vitals

        describe "@source.deployment should identify ELK instances" do

         sample("@type" => "syslog", "@message" => '<6>2015-11-25T12:28:10Z a9ffd17a-ec13-48e9-6091-38664ceee810 nats-to-syslog[20322]: {"Data":"{\"job\":\"elasticsearch_data-partition-6f559905a5a2abd801de\",\"index\":0,\"job_state\":\"running\",\"vitals\":{\"cpu\":{\"sys\":\"0.0\",\"user\":\"0.1\",\"wait\":\"0.1\"},\"disk\":{\"ephemeral\":{\"inode_percent\":\"2.0\",\"percent\":\"5.0\"},\"persistent\":{\"inode_percent\":\"44.0\",\"percent\":\"54.0\"}, \"system\":{\"inode_percent\":\"37.0\",\"percent\":\"46.0\"}},\"load\":[\"0.00\",\"0.02\",\"0.05\"],\"mem\":{\"kb\":\"81812.0\",\"percent\":\"8.0\"},\"swap\":{\"kb\":\"0.0\",\"percent\":\"0.0\"}},\"node_id\":\"\"}","Reply":"","Subject":"hm.agent.heartbeat.192dc853-4f1a-4198-8844-d0ab8d7c2c8e"}') do


            insist { subject["@source"]["deployment"] } == "ELK"
          end

        end # describe "@source.deployment should identify ELK instances

    end # describe "hm_agent_heartbeat"

#    describe "hm_alerts" do
#
#      sample("@type" => "NATS",
#    "subject" => "hm.director.alert", "reply" => nil,
#    "@message" => '{"id":"24fb3036-b183-41cf-7954-29aa20692601","severity":4,"title":"SSH Login","summary":"Accepted publickey for bosh_qmp1eh1q5 from 10.0.0.250 port 40317 ssh2: RSA 7c:87:b0:d2:7b:83:c1:b2:2c:b6:e5:d9:40:82:42:62","created_at":1444314808}') do
#
#           puts subject.to_hash.awesome_inspect
#
#        insist { subject["tags"] } == [ "NATS", "hm_alert" ]
#        insist { subject["@metadata"]["type"] } == "NATS"
#    insist { subject["@timestamp"] } == Time.iso8601("2015-10-08T14:33:28.000Z")
#    insist { subject["@level"] } == "WARN"
#
#    insist { subject["NATS"]["subject"] } == "hm.director.alert"
#    insist { subject["NATS"]["reply"] }.nil?
#
#    insist { subject["NATS"]["title"] } == "SSH Login"
#    insist { subject["NATS"]["summary"] } == "Accepted publickey for bosh_qmp1eh1q5 from 10.0.0.250 port 40317 ssh2: RSA 7c:87:b0:d2:7b:83:c1:b2:2c:b6:e5:d9:40:82:42:62"
#
#      end
#
#   end # describe hm_alerts
  end # describe "Parse BOSH nats messages"

end # describe LogStash::Filters::Grok do

