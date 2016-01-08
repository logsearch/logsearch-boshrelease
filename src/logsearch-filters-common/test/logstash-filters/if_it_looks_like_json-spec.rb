# encoding: utf-8
require "test/filter_test_helpers"

describe 'Log type autodetection' do

  before(:all) do
      @config = <<-CONFIG
        filter {
          #{File.read('target/logstash-filters-default.conf')}
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
        expect(log['tags']).to include("json/auto_detect")
      end
      it "it parses the JSON into a key named syslog_program" do
        expect(log['a4baede3_cb2a_4e1d_b6d4_8e34e4633149']).to eq( {
            "timestamp" => "2016-01-08T15:52:56Z",
        "response_time" => "0.110",
             "tls_time" => "0.011",
             "tcp_time" => "0.005",
                  "url" => "https://test-api.platform.cloudcredo.io/status",
                  "app" => "ccp-response-times"
        })
      end
    end

    context "when it looks like JSON but isn't" do
      when_parsing_log(
        '@type' => "syslog",
        '@message' => '287 <14>1 2016-01-08T15:52:56.74351+00:00 loggregator a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - { I might look like JSON, but I\\m not'
      ) do

        it "it does not get parsed as JSON" do
          expect(log['tags']).to_not include("json/auto_detect")
          expect(log['tags']).to_not include("_jsonparsefailure")
        end
      end
    end

    context "when it doesn't look like JSON" do
      when_parsing_log(
        '@type' => "syslog",
        '@message' => '287 <14>1 2016-01-08T15:52:56.74351+00:00 loggregator a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - IAMNOTJSON'
      ) do

        it "it does not get parsed as JSON" do
          expect(log['tags']).to_not include("json/auto_detect")
          expect(log['tags']).to_not include("_jsonparsefailure")
        end
      end
    end

  end
end

