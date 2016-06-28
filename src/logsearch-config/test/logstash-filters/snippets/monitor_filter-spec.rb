# encoding: utf-8
require 'test/filter_test_helpers'

describe "Rules for parsing haproxy messages" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
    #{File.read("src/logstash-filters/snippets/monitor_filter.conf")}
      }
    CONFIG
  end

  context 'when parsing a log with syslog structured data' do
    when_parsing_log(
      "syslog_sd_params" => { "job" => "elasticsearch_master", "index" => "1" },
      "syslog_program" => "elasticsearch",
      "@message" => '[2016-06-27 16:01:23,777][INFO ][node                     ] [elasticsearch_master/0] started'
    ) do

      it "sets @source.job" do
        expect(subject["@source"]["job"]).to eq "elasticsearch_master"
      end

      it "sets @source.index" do
        expect(subject["@source"]["index"]).to eq 1
      end

      it "sets @source.program" do
        expect(subject["@source"]["program"]).to eq "elasticsearch"
      end
    end
  end
end
