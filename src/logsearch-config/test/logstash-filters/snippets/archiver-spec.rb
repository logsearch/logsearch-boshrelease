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

  context "when parsing upload logs" do
    context "when the upload succeeds" do
      when_parsing_log(
        "syslog_program" => "archiver",
        "syslog_sd_params" => {"job" => "parser", "index" => "0"},
        "@message" => '{"timestamp":"1464881100.660612106","source":"ServiceBackup","message":"ServiceBackup.Upload backup completed without error","log_level":1,"data":{"duration_in_seconds":0.65,"size_in_bytes":1000}}'
      ) do
        it "adds the archiver tag" do
          expect(subject["tags"]).to include "archiver"
        end

        it "sets @source.job" do
          expect(subject["@source"]["job"]).to eq "parser"
        end

        it "sets @source.index" do
          expect(subject["@source"]["index"]).to eq 0
        end

        it "sets upload_status to SUCCESS" do
          expect(subject["archiver"]["upload_status"]).to eq "SUCCESS"
        end

        it "extracts the archiving duration" do
          expect(subject["archiver"]["duration"]).to eq 0.65
        end

        it "extracts the archive size" do
          expect(subject["archiver"]["size"]).to eq 1000
        end
      end
    end
    context "when the upload fails" do
      when_parsing_log(
        "syslog_program" => "archiver",
        "syslog_sd_params" => {"job" => "parser", "index" => "0"},
        "@message" => '{"timestamp":"1464787750.651552916","source":"ServiceBackup","message":"ServiceBackup.Upload backup completed with error","log_level":2,"data":{"error":"error in sync: exit status 1, output: A client error (SignatureDoesNotMatch) occurred when calling the ListObjects operation: The request signature we calculated does not match the signature you provided. Check your key and signing method.\nCompleted 1 part(s) with ... file(s) remaining\r\n"}}'
      ) do

        it "adds the a archiver tag" do
          expect(subject["tags"]).to include "archiver"
        end

        it "sets upload_status to FAILURE" do
          expect(subject["archiver"]["upload_status"]).to eq "FAILURE"
        end
      end
    end
  end

  context "when parsing other logs" do
    when_parsing_log(
      "syslog_program" => "archiver",
      "syslog_sd_params" => {"job" => "parser", "index" => "0"},
      "@message" => '{"timestamp":"1464786002.137657881","source":"ServiceBackup","message":"ServiceBackup.Cleanup completed without error","log_level":1,"data":{}}'
    ) do

      it "adds the a archiver tag" do
        expect(subject["tags"]).to include "archiver"
      end

      it "doesn't set upload_status" do
        expect(subject["archiver"]).to be_nil
      end
    end
  end
end

