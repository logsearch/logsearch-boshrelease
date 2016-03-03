# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'awesome_print'
require 'logstash/filters/alter'
require 'logstash/filters/grok'
require "pry"
require 'json'

class LogStashPipeline
  class << self
    def instance=(instance)
      @the_pipeline = instance
    end

    def instance
      @the_pipeline
    end

    private :new
  end
end

def load_filters(filters)
   pipeline = LogStash::Pipeline.new(filters)
   pipeline.instance_eval { @filters.each(&:register) }

   LogStashPipeline.instance = pipeline
end

def when_parsing_log(sample_event, &block)
  name = ""
	if sample_event.is_a?(String)
		name = sample_event
		sample_event = { '@type' => 'syslog', '@message' => sample_event }
	else
		name = LogStash::Json.dump(sample_event)
	end

	name = name[0..200] + "..." if name.length > 200

	describe "given: \"#{name}\"" do

		before(:all) do
			event = LogStash::Event.new(sample_event)

			results = []
			# filter call the block on all filtered events, included new events added by the filter
			LogStashPipeline.instance.filter(event) { |filtered_event| results << filtered_event }
			# flush makes sure to empty any buffered events in the filter
			LogStashPipeline.instance.flush_filters(:final => true) { |flushed_event| results << flushed_event }

			@parsed_results = results.select { |e| !e.cancelled? }
		end

		subject(:parsed_results) { @parsed_results.first }

		describe("it", &block)
	end
end
