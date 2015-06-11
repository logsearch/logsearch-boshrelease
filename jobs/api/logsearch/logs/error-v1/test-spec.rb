# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/grok"

describe LogStash::Filters::Grok do

  describe 'logsearch/nginx/access/v1' do
    config 'filter {' + File.read("#{File.dirname(__FILE__)}/logstash-filters.conf") + '}'

    sample('@message' => '2015/03/12 16:10:39 [error] 32022#0: *162 access forbidden by rule, client: 192.0.2.100, server: logsearch, request: "GET /favicon.ico HTTP/1.1", host: "api.logsearch.example.com"') do
      insist { subject['tags'] }.nil?
      insist { subject['@timestamp'] } === Time.iso8601('2015-03-12T16:10:39Z')

      insist { subject['severity'] } === 'error'
      insist { subject['worker_pid'] } === 32022
      insist { subject['worker_thread'] } === 0
      insist { subject['message'] } === '*162 access forbidden by rule, client: 192.0.2.100, server: logsearch, request: "GET /favicon.ico HTTP/1.1", host: "api.logsearch.example.com"'

      insist { subject.to_hash.keys.sort } === [
        '@message',
        '@timestamp',
        '@version',
        'message',
        'severity',
        'worker_pid',
        'worker_thread',
      ]
    end
  end
end
