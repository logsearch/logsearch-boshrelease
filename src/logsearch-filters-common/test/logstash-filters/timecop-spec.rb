# encoding: utf-8
require 'test/filter_test_helpers'

def future_timestamp
 LogStash::Timestamp.new(Time.parse("2515-12-22T11:00:00.000Z")) # 500 years in the future
end
def past_timestamp
 LogStash::Timestamp.new(Time.parse("1871-10-18T15:00:00.000Z")) # A significant date from the distant past
end

describe "Rules sanitising @timestamp" do

  before(:all) do
    @config = <<-CONFIG
      filter {
        #{File.read('src/logstash-filters/timecop.conf')}
      }
    CONFIG
    ENV['TIMECOP_REJECT_LESS_THAN_HOURS'] = '1'
  end

  context 'when parsing messages from the future' do

    when_parsing_log(
      '@timestamp' => future_timestamp,
      '@raw' => "#{future_timestamp} Hello from the future!",
      'extracted_field' => 'value'
    ) do

      it "adds a timecop triggered tag" do
        expect(log['tags']).to include("fail/timecop")
      end

      it "moves the invalid timestamp into invalid_fields.@timestamp" do
        expect(log['invalid_fields']['@timestamp']).to eq future_timestamp
      end

      it "resets the @timestamp to the current time" do
        expect(log['@timestamp']).to be_within(60).of Time.now
      end

      it "removes all the extracted fields leaving just @raw" do
        expect(log['@raw']).to eq("#{future_timestamp} Hello from the future!")
        expect(log['extracted_field']).to be_nil
      end

    end
  end

  context 'when parsing messages from the distant past' do

    when_parsing_log(
      '@timestamp' => past_timestamp,
      '@raw' => "#{past_timestamp} Hello from the past!",
      'extracted_field' => 'value'
    ) do

      it "adds a timecop triggered tag" do
        expect(log['tags']).to include("fail/timecop")
      end

      it "moves the invalid timestamp into invalid_fields.@timestamp" do
        expect(log['invalid_fields']['@timestamp']).to eq past_timestamp
      end

      it "resets the @timestamp to the current time" do
        expect(log['@timestamp']).to be_within(60).of Time.now
      end

      it "removes all the extracted fields leaving just @raw" do
        expect(log['@raw']).to eq("#{past_timestamp} Hello from the past!")
        expect(log['extracted_field']).to be_nil
      end

    end
  end

end
