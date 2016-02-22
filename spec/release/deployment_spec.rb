require 'json'
require 'uri'
require 'prof/ssh_gateway'

require "support/integration_helpers"

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

