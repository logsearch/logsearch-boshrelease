require 'test_utils'
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe 'logsearch/elasticsearch/stdout/v1' do
    config 'filter {' + File.read("#{File.dirname(__FILE__)}/../../../src/logstash-filters/snippets/elasticsearch-stdout-v1.conf") + '}'

    sample('@message' => '[2015-03-13 19:17:23,557][INFO ][cluster.routing.allocation.decider] [log_parser/0] updating [cluster.routing.allocation.enable] from [PRIMARIES] to [ALL]') do
      insist { subject['tags'] }.nil?
      #insist { subject['@timestamp'] } === Time.iso8601('2015-03-13T19:17:23.557Z')

      insist { subject['level'] } === 'INFO'
      insist { subject['logger'] } === 'cluster.routing.allocation.decider'
      insist { subject['node'] } === 'log_parser/0'
      insist { subject['message'] } === 'updating [cluster.routing.allocation.enable] from [PRIMARIES] to [ALL]'

      insist { subject.to_hash.keys.sort } === [
        '@message',
        '@timestamp',
        '@version',
        'level',
        'logger',
        'message',
        'node',
      ]
    end
  end
end
