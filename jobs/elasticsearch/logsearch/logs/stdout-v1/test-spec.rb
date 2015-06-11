# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"

  describe 'logsearch/elasticsearch/stdout/v1' do
    config 'filter {' + File.read("#{File.dirname(__FILE__)}/logstash-filters.conf") + '}'

    sample('@message' => '[2015-03-13 19:17:23,557][INFO ][cluster.routing.allocation.decider] [log_parser/0] updating [cluster.routing.allocation.enable] from [PRIMARIES] to [ALL]') do

      insist { subject['tags'] }.nil?
      insist { subject['@timestamp'] } === Time.iso8601('2015-03-13T19:17:23.557Z')

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
    
    describe 'slowlog' do
      sample('@message' => '[2015-04-07 13:18:55,920][DEBUG][index.search.slowlog.query] [elasticsearch_eu-west-1b/2] [logstash-2015.04.07][1] took[5.4s], took_millis[5417], types[type1,type2], stats[stat1,stat2], search_type[QUERY_THEN_FETCH], total_shards[4], source[{"query":{"match_all":{}},"size":0}], extra_source[{"timeout":15000}],') do
        insist { subject['tags'] }.nil?
        insist { subject['@timestamp'] } === Time.iso8601('2015-04-07T13:18:55.920Z')

        insist { subject['level'] } === 'DEBUG'
        insist { subject['logger'] } === 'index.search.slowlog.query'
        insist { subject['node'] } === 'elasticsearch_eu-west-1b/2'
        insist { subject['message'] } === '[logstash-2015.04.07][1] took[5.4s], took_millis[5417], types[type1,type2], stats[stat1,stat2], search_type[QUERY_THEN_FETCH], total_shards[4], source[{"query":{"match_all":{}},"size":0}], extra_source[{"timeout":15000}],'

        insist { subject['slowlog_index'] } === 'logstash-2015.04.07'
        insist { subject['slowlog_shard'] } === 1
        insist { subject['slowlog_took_millis'] } === 5417
        insist { subject['slowlog_types'] } === [ 'type1', 'type2' ]
        insist { subject['slowlog_stats'] } === [ 'stat1', 'stat2' ]
        insist { subject['slowlog_search_type'] } === 'QUERY_THEN_FETCH'
        insist { subject['slowlog_total_shards'] } === 4
        insist { subject['slowlog_source'] } === '{"query":{"match_all":{}},"size":0}'
        insist { subject['slowlog_extra_source'] } === '{"timeout":15000}'

        insist { subject.to_hash.keys.sort } === [
          '@message',
          '@timestamp',
          '@version',
          'level',
          'logger',
          'message',
          'node',
          'slowlog_extra_source',
          'slowlog_index',
          'slowlog_search_type',
          'slowlog_shard',
          'slowlog_source',
          'slowlog_stats',
          'slowlog_took_millis',
          'slowlog_total_shards',
          'slowlog_types',
        ]
      end

      sample('@message' => '[2015-04-07 13:18:55,920][DEBUG][index.search.slowlog.query] [elasticsearch_eu-west-1b/2] [logstash-2015.04.07][1] took[5.4s], took_millis[5417], types[type1], stats[], search_type[QUERY_THEN_FETCH], total_shards[4], source[{"query":{"match_all":{}},"size":0}], extra_source[],') do
        insist { subject['tags'] }.nil?
        insist { subject['@timestamp'] } === Time.iso8601('2015-04-07T13:18:55.920Z')

        insist { subject['level'] } === 'DEBUG'
        insist { subject['logger'] } === 'index.search.slowlog.query'
        insist { subject['node'] } === 'elasticsearch_eu-west-1b/2'
        insist { subject['message'] } === '[logstash-2015.04.07][1] took[5.4s], took_millis[5417], types[type1], stats[], search_type[QUERY_THEN_FETCH], total_shards[4], source[{"query":{"match_all":{}},"size":0}], extra_source[],'

        insist { subject['slowlog_index'] } === 'logstash-2015.04.07'
        insist { subject['slowlog_shard'] } === 1
        insist { subject['slowlog_took_millis'] } === 5417
        insist { subject['slowlog_types'] } === [ 'type1' ]
        insist { subject['slowlog_stats'] }.nil?
        insist { subject['slowlog_search_type'] } === 'QUERY_THEN_FETCH'
        insist { subject['slowlog_total_shards'] } === 4
        insist { subject['slowlog_source'] } === '{"query":{"match_all":{}},"size":0}'
        insist { subject['slowlog_extra_source'] }.nil?

        insist { subject.to_hash.keys.sort } === [
          '@message',
          '@timestamp',
          '@version',
          'level',
          'logger',
          'message',
          'node',
          'slowlog_index',
          'slowlog_search_type',
          'slowlog_shard',
          'slowlog_source',
          'slowlog_took_millis',
          'slowlog_total_shards',
          'slowlog_types',
        ]
      end
    end
  end
