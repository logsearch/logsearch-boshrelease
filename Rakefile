require 'erb'
require 'rake'

namespace :dev_release do
	desc "Creates and uploads DEV release to currently targeted BOSH."
	task :create_and_upload do
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh create release --force"
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh -n upload release"
	end
	desc "Creates, uploads and deploys DEV release to currently targeted BOSH deployment manifest"
	task :create_and_upload_and_deploy => :create_and_upload  do
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh -n deploy"
	end
end

namespace :lumberjack do
	
	desc "Generate new development lumberjack keys to lumberjack.key & lumberjack.crt"
	task :generate_keys do 
		sh "openssl req -days 3650 -x509 -batch -nodes -newkey rsa:1024 -keyout lumberjack.key -out lumberjack.crt"
	end

	desc "Forwards logs pasted into stdin to bosh-lite cluster"
	task :forward_stdin_to_bosh_lite do 
		sh "logstash-forwarder -config=spec/smoke/stdin_to_bosh-lite.json"
	end	
end

namespace :logstash_filters do
	task :clean do
	  mkdir_p "target"
	  rm_rf "target/*"
	end
	
	desc "Builds filters & dashboards"
	task :build => :clean do
	  puts "===> Building ..."
	  compile_erb 'src/logstash-filters/default.conf.erb', 'target/logstash-filters/default.conf'
	
	  puts "===> Artifacts:"
	  puts `tree target`
	end
	
	desc "Runs unit tests against filters & dashboards"
	task :test, [:rspec_files] => :build do |t, args|
	  args.with_defaults(:rspec_files => "$(find spec/logstash-filters -name *spec.rb)")
		puts "===> Testing ..."
	  sh %Q[vendor/logstash/bin/rspec #{args[:rspec_files]} ]
	end
	
end #namespace logstash-filters

def compile_erb(source_file, dest_file)
  if File.extname(source_file) == '.erb'
    output = ERB.new(File.read(source_file)).result(binding)
    File.write(dest_file, output)
  else
    cp source_file, dest_file
  end
end