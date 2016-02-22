require 'time'
require 'securerandom'
require 'yaml'

class Deployment
  def initialize(hash)
    @deployment = hash
  end

  def ingestor_ip
    find_job("ingestor")["networks"].first["static_ips"].first
  end

  def master_ip
    find_job("elasticsearch_master")["networks"].first["static_ips"].first
  end

  private

  def find_job(job_name)
    @deployment["jobs"].find { |job| job["name"] == job_name }
  end

  def self.load_file(path)
    new(YAML.load_file(path))
  end
end

class TestLog
  attr_reader :data, :time

  def initialize
    @time = LogTime.new
    @data = SecureRandom.hex(20)
  end

  def line
    "287 <14>1 #{time.iso8601} TESTLOG a4baede3-cb2a-4e1d-b6d4-8e34e4633149 [App/0] - - #{ {testvalue: data}.to_json }"
  end
end

class LogTime
  def initialize
    @now = Time.now
  end

  def iso8601
    @now.iso8601
  end

  def day
    @now.strftime("%Y.%m.%d")
  end
end

