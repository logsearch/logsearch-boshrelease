# encoding: utf-8
require "test/filter_test_helpers"

describe 'Log type autodetection' do

  before(:all) do
      load_filters <<-CONFIG
        filter {
		      #{File.read('target/logstash-filters-syslog-standard.conf')}
          #{File.read('target/logstash-filters-bosh-nats.conf')}
          #{File.read('target/logstash-filters-haproxy.conf')}
          #{File.read('src/logstash-filters/if_it_looks_like_json.conf')}
        }
    CONFIG
  end

  context "when parsing messages with no explicit type that look like JSON log messages" do
    when_parsing_log(
      '@type' => "syslog",
      '@message' => '287 <14>1 2016-01-08T15:52:56.74351+00:00 loggregator a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - { "timestamp":"2016-01-08T15:52:56Z", "response_time":"0.110", "tls_time":"0.011", "tcp_time":"0.005", "url":"https://test-api.platform.cloudcredo.io/status", "app":"ccp-response-times" }'
    ) do

      it "it gets parsed as JSON" do
        expect(subject['tags']).to include("json/auto_detect")
      end
      it "it parses the JSON into a key named syslog_program" do
        expect(subject['a4baede3_cb2a_4e1d_b6d4_8e34e4633149']).to eq( {
            "timestamp" => "2016-01-08T15:52:56Z",
        "response_time" => "0.110",
             "tls_time" => "0.011",
             "tcp_time" => "0.005",
                  "url" => "https://test-api.platform.cloudcredo.io/status",
                  "app" => "ccp-response-times"
        })
      end
    end

    context "when parsing messages with @source.program set" do
      when_parsing_log(
        '@source' => { 'program' => 'program_name' },
        '@message' => '{ "timestamp":"2016-01-08T15:52:56Z", "response_time":"0.110", "tls_time":"0.011", "tcp_time":"0.005", "url":"https://test-api.platform.cloudcredo.io/status", "app":"ccp-response-times" }'
      ) do

        it "it gets parsed as JSON" do
          expect(subject['tags']).to include("json/auto_detect")
        end
        it "it parses the JSON into a key named @source.program" do
          expect(subject['program_name']).to eq( {
              "timestamp" => "2016-01-08T15:52:56Z",
          "response_time" => "0.110",
               "tls_time" => "0.011",
               "tcp_time" => "0.005",
                    "url" => "https://test-api.platform.cloudcredo.io/status",
                    "app" => "ccp-response-times"
          })
        end
      end
    end

    describe "Extracting UnixNano timestamp fields" do
      context "when timestamp is a number" do
        when_parsing_log(
          '@source' => { 'program' => 'program_name' },
          '@message' => '{"timestamp":1458655387.3279622,"message":"Completed 200 vcap-request-id: e3d06207-b178-4dd4-7ac8-99eb89dbeae4::bb4989dc-d0c3-4680-84a0-e9515db0ccb8","log_level":"info","source":"cc.api","data":{},"thread_id":47073419309700,"fiber_id":47073422165060,"process_id":3255,"file":"/var/vcap/packages/cloud_controller_ng/cloud_controller_ng/middleware/request_logs.rb","lineno":23,"method":"call"}'
        ) do

          it "it gets parsed as JSON" do
            expect(subject['tags']).to include("json/auto_detect")
          end
          it "it extracts the timestamp" do
            expect(subject['tags']).to include("json/hoist_@timestamp")
          end
          it "it extracts the millisecond portion of the timestamp into @timestamp" do
            expect(subject['@timestamp']).to eq Time.parse('2016-03-22T14:03:07.327Z')
          end
          it "it extracts the nanoseconds into @timestamp_ns" do
            expect(subject['@timestamp_ns']).to eq 9622
          end
        end
      end
      context "when timestamp is a string" do
        when_parsing_log(
          '@source' => { 'program' => 'program_name' },
          '@message' => '{"timestamp":"1458655387.3279622","message":"Completed 200 vcap-request-id: e3d06207-b178-4dd4-7ac8-99eb89dbeae4::bb4989dc-d0c3-4680-84a0-e9515db0ccb8","log_level":"info","source":"cc.api","data":{},"thread_id":47073419309700,"fiber_id":47073422165060,"process_id":3255,"file":"/var/vcap/packages/cloud_controller_ng/cloud_controller_ng/middleware/request_logs.rb","lineno":23,"method":"call"}'
        ) do

          it "it gets parsed as JSON" do
            expect(subject['tags']).to include("json/auto_detect")
          end
          it "it extracts the timestamp" do
            expect(subject['tags']).to include("json/hoist_@timestamp")
          end
          it "it extracts the millisecond portion of the timestamp into @timestamp" do
            expect(subject['@timestamp']).to eq Time.parse('2016-03-22T14:03:07.327Z')
          end
          it "it extracts the nanoseconds into @timestamp_ns" do
            expect(subject['@timestamp_ns']).to eq 9622
          end
        end
      end
    end

    context "when it looks like JSON but isn't" do
      when_parsing_log(
        '@type' => "syslog",
        '@message' => '287 <14>1 2016-01-08T15:52:56.74351+00:00 loggregator a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - { I might look like JSON, but I\\m not'
      ) do

        it "it does not get parsed as JSON" do
          expect(subject['tags']).to_not include("json/auto_detect")
          expect(subject['tags']).to_not include("_jsonparsefailure")
        end
      end
    end

    context "when it doesn't look like JSON" do
      when_parsing_log(
        '@type' => "syslog",
        '@message' => '287 <14>1 2016-01-08T15:52:56.74351+00:00 loggregator a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - IAMNOTJSON'
      ) do

        it "it does not get parsed as JSON" do
          expect(subject['tags']).to_not include("json/auto_detect")
          expect(subject['tags']).to_not include("_jsonparsefailure")
        end
      end
    end

  end
end

