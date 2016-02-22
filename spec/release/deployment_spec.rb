require 'spec_helper'

require 'net/ssh'
require 'net/http'
require 'socket'
require 'securerandom'
require 'yaml'
require 'json'
require 'uri'
require 'time'

describe "LogSearch deployment" do
  it "ingests logs" do
    bosh_target = URI.parse(ENV["BOSH_TARGET"]).hostname
    bosh_username = ENV["BOSH_USERNAME"]
    ssh_key = ENV["BOSH_INSTANCE_SSH_KEY"]

    deployment = YAML.load_file(ENV["BOSH_MANIFEST"])
    ingestor_ip = deployment["jobs"].find { |job| job["name"] == "ingestor" }["networks"].first["static_ips"].first
    master_ip = deployment["jobs"].find { |job| job["name"] == "elasticsearch_master" }["networks"].first["static_ips"].first
    puts ENV.inspect
    puts master_ip
    puts ingestor_ip

    Thread.new do
      Net::SSH.start(bosh_target, bosh_username, keys: [ssh_key]) do |ssh|
        ssh.forward.local(5514, ingestor_ip, 5514)
        ssh.forward.local(9200, master_ip, 9200)

        ssh.loop { true }

      end
    end

    sleep 5

    logger = TCPSocket.new("localhost", 5514)
    testvalue = SecureRandom.uuid
    now = Time.now
    logger.puts("287 <14>1 #{now.iso8601} TESTLOG a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - { \"testvalue\":\"#{testvalue}\"}")

    sleep 5

    today = now.strftime("%Y.%m.%d")
    index = "logstash-#{today}"
    uri = URI("http://localhost:9200/#{index}/_search?q=#{testvalue}")
    puts uri

    response = JSON.parse(Net::HTTP.get(uri))
    puts response
    expect(response["hits"]["hits"].first["_source"]["a4baede3_cb2a_4e1d_b6d4_8e34e4633149"]["testvalue"]).to eq testvalue
  end
end

