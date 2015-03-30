require 'test_utils'
require 'logstash/filters/grok'

describe LogStash::Filters::Grok do
  extend LogStash::RSpec

  describe 'logsearch/nginx/access/v1' do
    config 'filter {' + File.read("#{File.dirname(__FILE__)}/../../../src/logstash-filters/snippets/nginx-access-v1.conf") + '}'

    sample('@message' => '192.0.2.1 - - [12/Mar/2015:16:50:01 +0000] "POST /logstash-2015.03.12/metric/_msearch HTTP/1.1" 200 1866 "-" "curl/7.35.0" 0.011') do
      insist { subject['tags'] }.nil?
      insist { subject['@timestamp'] } === Time.iso8601('2015-03-12T16:50:01Z')

      insist { subject['remote_addr'] } === '192.0.2.1'
      insist { subject['remote_user'] } === '-'
      insist { subject['request_method'] } === 'POST'
      insist { subject['request_uri'] } === '/logstash-2015.03.12/metric/_msearch'
      insist { subject['request_httpversion'] } === '1.1'
      insist { subject['status'] } === 200
      insist { subject['body_bytes_sent'] } === 1866
      insist { subject['http_user_agent'] } === '"curl/7.35.0"'
      insist { subject['request_time'] } === 0.011

      insist { subject.to_hash.keys.sort } === [
        '@message',
        '@timestamp',
        '@version',
        'body_bytes_sent',
        'http_user_agent',
        'remote_addr',
        'remote_user',
        'request_httpversion',
        'request_method',
        'request_time',
        'request_uri',
        'status',
      ]
    end
  end
end
