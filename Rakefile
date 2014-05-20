require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

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