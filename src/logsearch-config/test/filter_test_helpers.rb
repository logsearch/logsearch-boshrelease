# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'awesome_print'
require 'logstash/filters/alter'
require 'logstash/filters/grok'
require "pry"
require 'json'

def when_parsing_log(sample_event, &block)
    name = sample_event.is_a?(String) ? sample_event : LogStash::Json.dump(sample_event)
    name = name[0..200] + "..." if name.length > 200

    describe "\"#{name}\"" do

    before(:all) do
      pipeline = LogStash::Pipeline.new(@config) 
      event = LogStash::Event.new(sample_event) 

      results = []
      pipeline.instance_eval { @filters.each(&:register) }
      # filter call the block on all filtered events, included new events added by the filter
      pipeline.filter(event) { |filtered_event| results << filtered_event }
      # flush makes sure to empty any buffered events in the filter
      pipeline.flush_filters(:final => true) { |flushed_event| results << flushed_event }
      @results = results.select { |e| !e.cancelled? }
    end

    subject(:log) { @results.first }

    describe("the parsing filter", &block)
  end
end
