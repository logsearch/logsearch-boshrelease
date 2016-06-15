# encoding: utf-8
require 'test/filter_test_helpers'

describe "Redact passwords filter" do
  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/redact_passwords.conf")}
      }
    CONFIG
  end

  context "when parsing logs with AWS credentials in it" do
    when_parsing_log(
      "@message" => '{"timestamp":"1464361200.410290003","source":"ServiceBackup","message":"ServiceBackup.Running command: \u0026{Path:/var/vcap/packages/aws-cli/bin/aws Args:[/var/vcap/packages/aws-cli/bin/aws --endpoint-url https://s3-eu-west-1.amazonaws.com s3 sync /var/vcap/store/parser/logs-to-be-archived s3://logsearch-backup/turkish/2016/05/27] Env:[AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY]}'
    ) do

      it "adds the redacted tag" do
	expect(subject["tags"]).to include "redacted"
      end

      it "redacts the access key id" do
	expect(subject["@message"]).to match /AWS_ACCESS_KEY_ID=AKI\*{6}/
	expect(subject["@message"]).to_not match /AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE/
      end

      it "redacts the secret access key" do
	expect(subject["@message"]).to match /AWS_SECRET_ACCESS_KEY=wJa\*{6}/
	expect(subject["@message"]).to_not match "AWS_ACCESS_KEY_ID=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      end
    end
  end
end
