require 'spec_helper'

require 'securerandom'
require 'yaml'
require 'json'
require 'uri'
require 'time'
require 'prof/ssh_gateway'

class LogTime
  def initialize
    @now = Time.now
  end

  def iso8601
    @now.iso8601
  end

  def day
    @now.strftime("%Y.%m.%d")
  end
end

class TestLog
  attr_reader :data, :time

  def initialize
    @time = LogTime.new
    @data = SecureRandom.hex(20)
  end

  def line
    "287 <14>1 #{time.iso8601} TESTLOG a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - #{ {testvalue: data}.to_json }"
  end
end

class Deployment
  def initialize(hash)
    @deployment = hash
  end

  def ingestor_ip
    @deployment["jobs"].find { |job| job["name"] == "ingestor" }["networks"].first["static_ips"].first
  end

  def master_ip
    @deployment["jobs"].find { |job| job["name"] == "elasticsearch_master" }["networks"].first["static_ips"].first
  end

  def self.load_file(path)
    new(YAML.load_file(path))
  end
end

describe "LogSearch deployment" do
  let(:bosh_target) { URI.parse(ENV["BOSH_TARGET"]).hostname }
  let(:ssh_key_file) { ENV["BOSH_INSTANCE_SSH_KEY"] }
  let(:deployment) { Deployment.load_file(ENV["BOSH_MANIFEST"]) }
  let(:log) { TestLog.new }
  let(:gateway) do
    Prof::SshGateway.new(
      gateway_host: bosh_target,
      gateway_username: 'vcap',
      ssh_key: File.read(ssh_key_file)
    )
  end

  it "ingests logs" do
    gateway.execute_on(deployment.ingestor_ip, "echo '#{log.line}' | nc localhost 5514")

    sleep 5

    index = "logstash-#{log.time.day}"
    uri = URI("http://localhost:9200/#{index}/_search?q=#{log.data}")
    output = gateway.execute_on(deployment.master_ip, "curl -s #{uri}")
    response = JSON.parse(output)
    expect(response["hits"]["hits"].first["_source"]["a4baede3_cb2a_4e1d_b6d4_8e34e4633149"]["testvalue"]).to eq log.data
  end
end

