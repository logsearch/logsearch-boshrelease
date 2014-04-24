describe "elasticsearch cluster" do

  it "messages shipped via logstash-forwarder ( lumberjack protocol ) should end up in elasticsearch" do    

    test_run_id = RSpec.configuration.seed
    config_path = process_erb "spec/smoke/sample_logs_to_bosh-lite.json.erb", {
     :test_run_id => test_run_id,
     :ingestor_host => RSpec.configuration.logsearch['ingestor_host']
    }

    `touch spec/smoke/sample_logs/nginx.access.log` #ensure this file is considered "new"

    ship_logs(config_path)

    retryable(:tries => 10, :sleep => 2) do |retries, exception|
      if exception
        puts "Search #{retries} failed.  Waiting 2s to allow logs to be processed, then trying again"
      end
      result = search "test_run_id:#{test_run_id}", "logstash-2013.06.06"
      result['hits']['total'].should eq(4)
    end

  end
end


