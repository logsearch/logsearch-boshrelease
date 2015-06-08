# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/grok"

describe 'logsearch/nginx/access/v2' do
  config "filter { #{File.read("src/logstash-filters/snippets/nginx-access-v2.conf")} }"

  sample('@message' => '10.10.66.43 - birdnest [07/May/2015:01:52:55 +0000] "GET /styles/main.css?_b=5930 HTTP/1.1" 304 0 "https://logsearch.com/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36" 0.003 "216.253.193.158" 127.0.0.1:5601 304 0.002' ) do
  
  #'192.0.2.1 - - [12/Mar/2015:16:50:01 +0000] "POST /logstash-2015.03.12/metric/_msearch HTTP/1.1" 200 1866 "-" "curl/7.35.0" 0.011') do
                       
    insist { subject['tags'] }.nil?
    insist { subject['@timestamp'] } === Time.iso8601('2015-05-07T01:52:55Z')

    insist { subject['remote_addr'] } === '10.10.66.43'
    insist { subject['remote_user'] } === 'birdnest'
    insist { subject['status'] } === 304
    insist { subject['request_method'] } === 'GET'
    insist { subject['request_uri'] } === '/styles/main.css?_b=5930'
    insist { subject['request_httpversion'] } === '1.1'
    insist { subject['body_bytes_sent'] } === 0
    insist { subject['http_referer'] } === 'https://logsearch.com/'
    insist { subject['http_user_agent'] } === '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36"'
    insist { subject['request_time'] } ===  0.003
    insist { subject['http_x_forwarded_for'] } === '216.253.193.158'
    insist { subject['upstream_addr'] } === '127.0.0.1'
    insist { subject['upstream_port'] } === '5601'
    insist { subject['upstream_status'] } === 304
    insist { subject['upstream_response_time'] } === 0.002

    insist { subject.to_hash.keys.sort } === [
      "@message", 
      "@timestamp", 
      "@version", 
      "body_bytes_sent", 
      "http_referer", 
      "http_user_agent", 
      "http_x_forwarded_for", 
      "remote_addr", 
      "remote_user", 
      "request_httpversion", 
      "request_method", 
      "request_time",
      "request_uri", 
      "status", 
      "upstream_addr", 
      "upstream_port", 
      "upstream_response_time", 
      "upstream_status"
    ]
  end
end

