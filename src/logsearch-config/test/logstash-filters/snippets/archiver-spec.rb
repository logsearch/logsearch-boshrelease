# encoding: utf-8
require 'test/filter_test_helpers'

describe "it parses logs from the archiver" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/archiver.conf")}
      }
    CONFIG
  end

  when_parsing_log(
    "syslog_program" => "archiver",
    "syslog_sd_params" => {"job" => "parser", "index" => "0"},
    "@message" => '{"timestamp":"1464366960.747321367","source":"ServiceBackup","message":"ServiceBackup.Upload backup completed without error","log_level":1,"data":{}}'
  ) do

    it "adds the a archiver tag" do
      expect(subject["tags"]).to include "archiver"
    end

    it "sets @source.job" do
      expect(subject["@source"]["job"]).to eq "parser"
    end

    it "sets @source.index" do
      expect(subject["@source"]["index"]).to eq "0"
    end
  end
end

