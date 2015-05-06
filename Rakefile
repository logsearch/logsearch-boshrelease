require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

target=""
target="#{target} -t #{ENV['BOSH_TARGET']}" if ENV['BOSH_TARGET']
target="#{target} -d #{ENV['BOSH_DEPLOYMENT']}" if ENV['BOSH_DEPLOYMENT']
target="#{target} -u #{ENV['BOSH_USER']}" if ENV['BOSH_USER']
target="#{target} -p #{ENV['BOSH_PASSWORD']}" if ENV['BOSH_PASSWORD']

namespace :dev_release do
	desc "Creates DEV release"
	task :create do
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "yes logsearch | bosh create release --force --with-tarball"
	end
	desc "Creates and uploads DEV release to currently targeted BOSH."
	task :create_and_upload => :create do
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh #{target} -n upload release"
	end
	desc "Creates, uploads and deploys DEV release to currently targeted BOSH deployment manifest"
	task :create_and_upload_and_deploy => :create_and_upload  do
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh #{target} -n deploy"
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