require 'rest-client'
require 'rspec_api_test'
require 'pty'
require 'erb'
require 'tempfile'
require 'retryable'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Add some custom config
  config.add_setting :logsearch, :default => {
    "api_url" => ENV['API_URL'] || "http://10.244.2.2:80",
    "ingestor_host" => ENV['INGESTOR_HOST'] || "10.244.2.14"
  }
end

RSpecAPITest.config = {
  base_url: "#{RSpec.configuration.logsearch['api_url']}",
  defaults: {
    content_type: :json,
    accept: :json
  }
}

########### Helper functions - should be moved into separate file(s) when enough accumulate here

# See http://stoneship.org/essays/erb-and-the-context-object/
class ERBContext
  def initialize(hash)
    hash.each_pair do |key, value|
      instance_variable_set('@' + key.to_s, value)
    end
  end

  def get_binding
    binding
  end
end

def process_erb(template, erb_variables = {})

  filename = File.basename(template,'erb')
  ext = File.extname(filename)

  out_file = Tempfile.new([filename, ext])
  out_file.puts(ERB.new(File.read(File.expand_path(template))).result(ERBContext.new(erb_variables).get_binding))
  out_file.close

  out_file.path
end

def ship_logs(logstash_forwarder_config_path) 

  host_os = RbConfig::CONFIG['host_os']
  case host_os
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    `del /s .logstash-forwarder*`
    run_until "spec/bin/windows/logstash-forwarder.exe -config=#{logstash_forwarder_config_path} -idle-flush-time=10ms -from-beginning=true",\
              /.*Registrar\ received.*/
    `del /s  .logstash-forwarder*`
  when /darwin|mac os/
    `rm -rf .logstash-forwarder*`
    run_until "spec/bin/mac/logstash-forwarder -config=#{logstash_forwarder_config_path} -idle-flush-time=10ms -from-beginning=true",\
              /.*Registrar\ received.*/
    `rm -rf .logstash-forwarder*`
  when /linux/
    `rm -rf .logstash-forwarder*`
    run_until "spec/bin/linux/logstash-forwarder -config=#{logstash_forwarder_config_path} -idle-flush-time=10ms -from-beginning=true",\
              /.*Registrar\ received.*/
    `rm -rf .logstash-forwarder*`
  else
    raise "Don't have a logstash-forwarder for os: #{host_os.inspect}"
  end

end

def search(query, index = "logstash-#{Time.now.strftime("%Y.%m.%d")}")
  body = {
    "query" => {
      "filtered" => {
        "query" => {
          "query_string" => {
            "query" => query
          }
        }
      }
    }
  }.to_json
  post("/#{index}/_search", body )
end

def run_until(cmd, exit_regex)
  unless File.exists?(cmd)
    cmd_file = Tempfile.new('run_until.sh')
    cmd_file.write("#!/usr/bin/env bash\n")
    cmd_file.write(cmd)
    cmd_file.close
    cmd = cmd_file.path
    File.chmod(0744, cmd)
  end
  PTY.spawn( cmd ) do |stdout_and_err, stdin, pid| 
    begin
      stdout_and_err.each do |line| 
        print line 
        if (line =~ exit_regex) 
          puts "Shutting down process #{pid}"
          Process.kill(-9, pid) # SIGTERM whole process group
        end
      end
    rescue Errno::EIO
      #ignore - see http://stackoverflow.com/questions/10238298/ruby-on-linux-pty-goes-away-without-eof-raises-errnoeio     
    end
    Process.wait(pid)
  end
end #run_until