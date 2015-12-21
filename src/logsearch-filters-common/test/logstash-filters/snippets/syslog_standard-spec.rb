# encoding: utf-8
require 'test/filter_test_helpers'

describe LogStash::Filters::Grok do

  config <<-CONFIG
    filter {
      #{File.read("src/logstash-filters/snippets/syslog_standard.conf")}
    }
  CONFIG

  describe "Accepting standard syslog message without PID specified" do
    sample("@message" => '<85>Apr 24 02:05:03 localhost sudo: bosh_h5156e598 : TTY=pts/0 ; PWD=/var/vcap/bosh_ssh/bosh_h5156e598 ; USER=root ; COMMAND=/bin/pwd') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("#{Time.now.year}-04-24T02:05:03.000Z")

      insist { subject['@source']['host'] } == 'localhost'
      insist { subject['syslog_hostname'] } == 'localhost'

      insist { subject['syslog_facility'] } == 'security/authorization'
      insist { subject['syslog_facility_code'] } == 10
      insist { subject['syslog_severity'] } == 'notice'
      insist { subject['syslog_severity_code'] } == 5
      insist { subject['syslog_program'] } == 'sudo'
      insist { subject['syslog_pid'] }.nil?
      insist { subject['@message'] } == 'bosh_h5156e598 : TTY=pts/0 ; PWD=/var/vcap/bosh_ssh/bosh_h5156e598 ; USER=root ; COMMAND=/bin/pwd'
    end
  end

  describe "Accepting standard syslog message with PID specified" do
    sample("@message" => '<78>Apr 24 04:03:06 localhost crontab[32185]: (root) LIST (root)') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("#{Time.now.year}-04-24T04:03:06.000Z")

      insist { subject['@source']['host'] } == 'localhost'
      insist { subject['syslog_hostname'] } == 'localhost'

      insist { subject['syslog_facility'] } == 'clock'
      insist { subject['syslog_facility_code'] } == 9
      insist { subject['syslog_severity'] } == 'informational'
      insist { subject['syslog_severity_code'] } == 6
      insist { subject['syslog_program'] } == 'crontab'
      insist { subject['syslog_pid'] } == '32185'
      insist { subject['@message'] } == '(root) LIST (root)'
    end
  end

  describe "Accepting Cloud Foundry syslog message with valid host" do
    sample("@message" => '<14>2014-04-23T23:19:01.227366+00:00 172.31.201.31 vcap.nats [job=vcap.nats index=1]  {\"timestamp\":1398295141.227022}') do
      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("2014-04-23T23:19:01.227Z")

      insist { subject['@source']['host'] } == '172.31.201.31'
      insist { subject['syslog_hostname'] } == '172.31.201.31'

      insist { subject['syslog_facility'] } == 'user-level'
      insist { subject['syslog_facility_code'] } == 1
      insist { subject['syslog_severity'] } == 'informational'
      insist { subject['syslog_severity_code'] } == 6
      insist { subject['syslog_program'] } == 'vcap.nats'
      insist { subject['syslog_pid'] }.nil?
      insist { subject['@message'] } == '[job=vcap.nats index=1]  {\"timestamp\":1398295141.227022}'
    end
  end

  describe "Invalid syslog message" do
    sample("@message" => '<78>Apr 24, this message should fail') do
      insist { subject["tags"] } == [ 'fail/syslog_standard/_grokparsefailure' ]
    end
  end

  describe "Cloud Foundry loggregator messages" do
    sample('@message' => '276 <14>1 2014-05-20T20:40:49+00:00 loggregator d5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc [App/0] - - {"@timestamp":"2014-05-20T20:40:49.907Z","message":"LowRequestRate 2014-05-20T15:44:58.794Z","@source.name":"watcher-bot-ppe","logger":"logsearch_watcher_bot.Program","level":"WARN"}') do
      insist { subject["tags"] } === [ 'syslog_standard' ]
      insist { subject["@timestamp"] } === Time.iso8601("2014-05-20T20:40:49Z")

      insist { subject['@source']['host'] } === 'loggregator'
      insist { subject['syslog_hostname'] } == 'loggregator'

      insist { subject['syslog_program'] } === 'd5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc'
      insist { subject['syslog6587_msglen'] } === 276
      insist { subject['syslog5424_ver'] } === 1
      insist { subject['syslog_severity_code'] } === 6
      insist { subject['syslog_severity'] } === 'informational'
      insist { subject['syslog_facility_code'] } === 1
      insist { subject['syslog_facility'] } === 'user-level'

      insist { subject['syslog_procid'] } == '[App/0]'
      insist { subject['syslog_msgid'] } == '-'
      insist { subject['@message'] } == '{"@timestamp":"2014-05-20T20:40:49.907Z","message":"LowRequestRate 2014-05-20T15:44:58.794Z","@source.name":"watcher-bot-ppe","logger":"logsearch_watcher_bot.Program","level":"WARN"}'
    end

    sample('@message' => '167 <14>1 2014-05-20T09:46:16+00:00 loggregator d5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc [App/0] - - Updating AppSettings for /home/vcap/app/logsearch-watcher-bot.exe.config') do
      insist { subject["tags"] } === [ 'syslog_standard' ]
      insist { subject["@timestamp"] } === Time.iso8601("2014-05-20T09:46:16Z")

      insist { subject['@source']['host'] } === 'loggregator'
      insist { subject['syslog_hostname'] } == 'loggregator'

      insist { subject['syslog_program'] } === 'd5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc'
      insist { subject['syslog6587_msglen'] } === 167
      insist { subject['syslog5424_ver'] } === 1
      insist { subject['syslog_severity_code'] } === 6
      insist { subject['syslog_severity'] } === 'informational'
      insist { subject['syslog_facility_code'] } === 1
      insist { subject['syslog_facility'] } === 'user-level'

      insist { subject['syslog_procid'] } == '[App/0]'
      insist { subject['syslog_msgid'] } == '-'
      insist { subject['@message'] } == 'Updating AppSettings for /home/vcap/app/logsearch-watcher-bot.exe.config'
    end

    sample('@message' => '94 <11>1 2014-05-20T09:46:07+00:00 loggregator d5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc [App/0] - -') do
      insist { subject["tags"] } === [ 'syslog_standard' ]
      insist { subject["@timestamp"] } === Time.iso8601("2014-05-20T09:46:07Z")

      insist { subject['@source']['host'] } === 'loggregator'
      insist { subject['syslog_hostname'] } == 'loggregator'

      insist { subject['syslog_program'] } === 'd5a5e8a5-9b06-4dd3-8157-e9bd3327b9dc'
      insist { subject['syslog6587_msglen'] } === 94
      insist { subject['syslog5424_ver'] } === 1
      insist { subject['syslog_severity_code'] } === 3
      insist { subject['syslog_severity'] } === 'error'
      insist { subject['syslog_facility_code'] } === 1
      insist { subject['syslog_facility'] } === 'user-level'

      insist { subject['syslog_procid'] } == '[App/0]'
      insist { subject['syslog_msgid'] } == '-'
      insist { subject['@message'] } == '-'
    end
  end

  describe "syslog_sd_params rules" do
    describe "when sd_params.host exists, @shipper.host = syslog_hostname, @source.host = sd_params.host" do
      sample("@message" => '<13>1 2015-09-24T11:16:12.808763+01:00 SYSLOG-HOST - - - [NXLOG@14506 host="SDPARAMS-HOST"] IOrderService.ListOpenPositions Duration 8ms') do
        insist { subject["tags"] } == [ 'syslog_standard' ]

        insist { subject['@shipper']['host'] } == 'SYSLOG-HOST'
        insist { subject['@source']['host'] } == 'SDPARAMS-HOST'
      end
    end
    describe "when sd_params.type exists, @type = sd_params.type, @message = @message" do
      sample("@message" => '<13>1 2015-09-24T11:16:12.808763+01:00 SYSLOG-HOST - - - [NXLOG@14506 type="SDPARAMS-TYPE"] IOrderService.ListOpenPositions Duration 8ms') do

        insist { subject["tags"] } == [ 'syslog_standard' ]

        insist { subject['@type'] } == 'SDPARAMS-TYPE'
        insist { subject['@message'] } == 'IOrderService.ListOpenPositions Duration 8ms'
      end
    end
  end

  describe "NXLOG message" do
    sample("@message" => '<13>1 2015-09-24T11:16:12.808763+01:00 PKH-PPE-WEB28 - - - [NXLOG@14506 EventReceivedTime="2015-09-24 11:16:12" SourceModuleName="in_file1" SourceModuleType="im_file" path="\\PKH-PPE-WEB24\\Logs\\TradingApi.log*.log" type="ci_log4net" host="PKH-PPE-WEB24" service="CI WEBSERVICE/TradingAPI" environment="PPE"] INFO  2015-09-24 11:16:12,501 42 CityIndex.TradingApi.Common.Logging.MethodTimeLogger Request 4133629: Action: IOrderService.ListOpenPositions Duration 8ms') do

      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("2015-09-24T10:16:12.808Z")

      insist { subject['@shipper']['host'] } == 'PKH-PPE-WEB28'
      insist { subject['@source']['host'] } == 'PKH-PPE-WEB24'
      insist { subject['syslog_hostname'] } == 'PKH-PPE-WEB28'

      insist { subject['syslog_sd_id'] } == 'NXLOG@14506'

      sd_params = subject['syslog_sd_params']
      insist { sd_params['EventReceivedTime'] } == '2015-09-24 11:16:12'
      insist { sd_params['SourceModuleName'] } == 'in_file1'
      insist { sd_params['SourceModuleType'] } == 'im_file'
      insist { sd_params['path'] } == '\PKH-PPE-WEB24\Logs\TradingApi.log*.log'
      insist { sd_params['type'] } == 'ci_log4net'
      insist { sd_params['host'] } == 'PKH-PPE-WEB24'
      insist { sd_params['service'] } == 'CI WEBSERVICE/TradingAPI'
      insist { sd_params['environment'] } == 'PPE'

      insist { subject['@type'] } == 'ci_log4net'
      insist { subject['@message'] } == 'INFO  2015-09-24 11:16:12,501 42 CityIndex.TradingApi.Common.Logging.MethodTimeLogger Request 4133629: Action: IOrderService.ListOpenPositions Duration 8ms'
    end
  end

  describe "log4net.Appenders.Contrib.RemoteSyslog5424Appender message" do
    sample("@message" => '221 <14>1 2015-09-18T13:07:32.553201Z LON-WS01351X G2Shell - - [fields@0 environment="PPE"] INFO  2015-09-18 14:07:32,553 SenderThread RemoteSyslog5424AppenderDiagLogger Connection to the server lost. Re-try in 10 seconds.') do

      insist { subject["tags"] } == [ 'syslog_standard' ]
      insist { subject["@timestamp"] } == Time.iso8601("2015-09-18T13:07:32.553Z")

      insist { subject['@source']['host'] } == 'LON-WS01351X'
      insist { subject['syslog_hostname'] } == 'LON-WS01351X'

      insist { subject['syslog_sd_id'] } == 'fields@0'
      insist { subject['syslog_sd_params']['environment'] } == 'PPE'

      insist { subject['@message'] } == 'INFO  2015-09-18 14:07:32,553 SenderThread RemoteSyslog5424AppenderDiagLogger Connection to the server lost. Re-try in 10 seconds.'
    end
  end

  context 'when parsing a sylog message in RFC3164 format from haproxy' do

    before(:all) do
      @config = <<-CONFIG
        filter {
          #{File.read("src/logstash-filters/snippets/syslog_standard.conf")}
        }
      CONFIG
    end

    when_parsing_log(
      '@message' => "<46>Dec 16 15:24:05 haproxy[9252]: 52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 SC 8/8/8/0/3 0/0",
      '@type' => 'syslog'
    ) do

      it "adds the syslog_standard tag" do
        expect(log['tags']).to include("syslog_standard")
      end
      it "extracts the timestamp" do
        expect(log['@timestamp']).to eq(Time.parse("2015-12-16T15:24:05Z"))
      end
      it "drops the syslog_timestamp field (since it has been captured in @timestamp)" do
        expect(log['syslog_timestamp']).to be_nil
      end
      it "extracts the syslog_program" do
        expect(log['syslog_program']).to eq("haproxy")
      end
      it "extracts the syslog_pid" do
        expect(log['syslog_pid']).to eq("9252")
      end
      it "extracts the syslog_message to @message" do
        expect(log['@message']).to eq("52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 SC 8/8/8/0/3 0/0")
      end
    end
  end
end
