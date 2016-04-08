# encoding: utf-8
require "test/filter_test_helpers"

describe 'Metric filters' do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read('target/logstash-filters-syslog-standard.conf')}
        #{File.read('target/logstash-filters-bosh-nats.conf')}
        #{File.read('target/logstash-filters-haproxy.conf')}
				#{File.read('target/logstash-filters-metric.conf')}
      }
    CONFIG
  end

  when_parsing_log(
    "@type" => "syslog",
    "@message" => ' <13>1 2016-01-04T12:03:31.236204+00:00 4fe781f0-30ed-4961-9aca-3efb9d73121a - - - [NXLOG@14506 bosh_director="default" bosh_deployment="logsearch" bosh_job="queue/0" bosh_template="logsearch-shipper" type="metric"] logstash.queue_size 100 1451909010'
  ) do

    it "applies the metric parsers successfully" do
      expect(subject['tags']).to include 'metric'
    end

    it "extracts the metric @timestamp" do
      expect(subject['@timestamp']).to eq Time.at(1451909010)
      expect(subject['metric']['timestamp']).to be_nil
    end

    it "extracts the metric name" do
      expect(subject['metric']['name']).to eq 'logstash.queue_size'
    end

    it "extracts the metric value" do
      expect(subject['metric']['value']).to eq 100.0
    end
  end

  when_parsing_log(
    "@type" => "syslog",
    "@message" => ' <13>1 2016-01-04T12:03:31.236204+00:00 4fe781f0-30ed-4961-9aca-3efb9d73121a - - - [NXLOG@14506 type="metric"] INVALID 1451909010'
  ) do

    it "applies the fail/metric tags for invalid logs" do
      expect(subject['tags']).to include 'fail/metric'
    end
  end
end
