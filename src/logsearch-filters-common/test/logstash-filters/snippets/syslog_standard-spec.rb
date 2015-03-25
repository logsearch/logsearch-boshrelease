# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/grok"

describe LogStash::Filters::Grok do

  config <<-CONFIG
    filter {
      #{File.read("src/logstash-filters/snippets/syslog_standard.conf")}
    }
  CONFIG

  describe "Accepting standard syslog message without PID specified" do
    sample("host" => "1.2.3.4:12345", "@message" => '<85>Apr 24 02:05:03 localhost sudo: bosh_h5156e598 : TTY=pts/0 ; PWD=/var/vcap/bosh_ssh/bosh_h5156e598 ; USER=root ; COMMAND=/bin/pwd') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("#{Time.now.year}-04-24T02:05:03.000Z")
      insist { subject['@source.host'] } == '1.2.3.4'

      insist { subject['syslog_facility'] } == 'security/authorization'
      insist { subject['syslog_facility_code'] } == 10
      insist { subject['syslog_severity'] } == 'notice'
      insist { subject['syslog_severity_code'] } == 5
      insist { subject['syslog_program'] } == 'sudo'
      insist { subject['syslog_pid'] }.nil?
      insist { subject['syslog_message'] } == 'bosh_h5156e598 : TTY=pts/0 ; PWD=/var/vcap/bosh_ssh/bosh_h5156e598 ; USER=root ; COMMAND=/bin/pwd'
    end
  end

  describe "Accepting standard syslog message with PID specified" do
    sample("host" => "1.2.3.4", "@message" => '<78>Apr 24 04:03:06 localhost crontab[32185]: (root) LIST (root)') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("#{Time.now.year}-04-24T04:03:06.000Z")
      insist { subject['@source.host'] } == '1.2.3.4'

      insist { subject['syslog_facility'] } == 'clock'
      insist { subject['syslog_facility_code'] } == 9
      insist { subject['syslog_severity'] } == 'informational'
      insist { subject['syslog_severity_code'] } == 6
      insist { subject['syslog_program'] } == 'crontab'
      insist { subject['syslog_pid'] } == '32185'
      insist { subject['syslog_message'] } == '(root) LIST (root)'
    end
  end

  describe "Accepting Cloud Foundry syslog message with valid host" do
    sample("host" => "1.2.3.4", "@message" => '<14>2014-04-23T23:19:01.227366+00:00 172.31.201.31 vcap.nats [job=vcap.nats index=1]  {\"timestamp\":1398295141.227022}') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("2014-04-23T23:19:01.227Z")
      insist { subject['@source.host'] } == '172.31.201.31'

      insist { subject['syslog_facility'] } == 'user-level'
      insist { subject['syslog_facility_code'] } == 1
      insist { subject['syslog_severity'] } == 'informational'
      insist { subject['syslog_severity_code'] } == 6
      insist { subject['syslog_program'] } == 'vcap.nats'
      insist { subject['syslog_pid'] }.nil?
      insist { subject['syslog_message'] } == '[job=vcap.nats index=1]  {\"timestamp\":1398295141.227022}'
    end
  end

  describe "Invalid syslog message" do
    sample("host" => "1.2.3.4", "@message" => '<78>Apr 24, this message should fail') do
      insist { subject["tags"] } == [ '_grokparsefailure-syslog_standard' ]
    end
  end

  describe "Cloud Foundry loggregator messages" do
    sample('host' => 'rspec', '@message' => '276 <14>1 2014-05-20T20:40:49+00:00 loggregator d5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc [App/0] - - {"@timestamp":"2014-05-20T20:40:49.907Z","message":"LowRequestRate 2014-05-20T15:44:58.794Z","@source.name":"watcher-bot-ppe","logger":"logsearch_watcher_bot.Program","level":"WARN"}') do
      insist { subject["tags"] } === [ 'syslog_standard' ]
      insist { subject["@timestamp"] } === Time.iso8601("2014-05-20T20:40:49Z")
      insist { subject['@source.host'] } === 'loggregator'
      insist { subject['syslog_program'] } === 'd5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc'

      insist { subject['syslog6587_msglen'] } === 276
      insist { subject['syslog5424_ver'] } === 1
      insist { subject['syslog_severity_code'] } === 6
      insist { subject['syslog_severity'] } === 'informational'
      insist { subject['syslog_facility_code'] } === 1
      insist { subject['syslog_facility'] } === 'user-level'

      insist { subject['syslog_procid'] } == '[App/0]'
      insist { subject['syslog_msgid'] } == '-'
      insist { subject['syslog_message'] } == '{"@timestamp":"2014-05-20T20:40:49.907Z","message":"LowRequestRate 2014-05-20T15:44:58.794Z","@source.name":"watcher-bot-ppe","logger":"logsearch_watcher_bot.Program","level":"WARN"}'

      insist { subject['received_at'] }.class == Time
      insist { subject['received_from'] } == 'rspec'
    end

    sample('host' => 'rspec', '@message' => '167 <14>1 2014-05-20T09:46:16+00:00 loggregator d5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc [App/0] - - Updating AppSettings for /home/vcap/app/logsearch-watcher-bot.exe.config') do
      insist { subject["tags"] } === [ 'syslog_standard' ]
      insist { subject["@timestamp"] } === Time.iso8601("2014-05-20T09:46:16Z")
      insist { subject['@source.host'] } === 'loggregator'
      insist { subject['syslog_program'] } === 'd5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc'

      insist { subject['syslog6587_msglen'] } === 167
      insist { subject['syslog5424_ver'] } === 1
      insist { subject['syslog_severity_code'] } === 6
      insist { subject['syslog_severity'] } === 'informational'
      insist { subject['syslog_facility_code'] } === 1
      insist { subject['syslog_facility'] } === 'user-level'

      insist { subject['syslog_procid'] } == '[App/0]'
      insist { subject['syslog_msgid'] } == '-'
      insist { subject['syslog_message'] } == 'Updating AppSettings for /home/vcap/app/logsearch-watcher-bot.exe.config'

      insist { subject['received_at'] }.class == Time
      insist { subject['received_from'] } == 'rspec'
    end

    sample('host' => 'rspec', '@message' => '94 <11>1 2014-05-20T09:46:07+00:00 loggregator d5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc [App/0] - -') do
      insist { subject["tags"] } === [ 'syslog_standard' ]
      insist { subject["@timestamp"] } === Time.iso8601("2014-05-20T09:46:07Z")
      insist { subject['@source.host'] } === 'loggregator'
      insist { subject['syslog_program'] } === 'd5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc'

      insist { subject['syslog6587_msglen'] } === 94
      insist { subject['syslog5424_ver'] } === 1
      insist { subject['syslog_severity_code'] } === 3
      insist { subject['syslog_severity'] } === 'error'
      insist { subject['syslog_facility_code'] } === 1
      insist { subject['syslog_facility'] } === 'user-level'

      insist { subject['syslog_procid'] } == '[App/0]'
      insist { subject['syslog_msgid'] } == '-'
      insist { subject['syslog_message'] } == '-'

      insist { subject['received_at'] }.class == Time
      insist { subject['received_from'] } == 'rspec'
    end
  end

end
