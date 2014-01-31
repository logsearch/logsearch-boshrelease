require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

namespace :bosh do
	desc "Creates, uploads and deploys release.  Useful when developing a release"
	task :create_and_deploy_release do
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh create release --force"
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh -n upload release"
		puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
		sh "bosh -n deploy"
	end
end

namespace :lumberjack do
	
	desc "Generate new lumberjack keys to lumberjack.key & lumberjack.crt"
	task :generate_keys do 
		sh "openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout lumberjack.key -out lumberjack.crt"
	end

	desc "Forwards logs pasted into stdin to bosh-lite cluster"
	task :forward_stdin_to_bosh_lite do 
		sh "logstash-forwarder -config=spec/smoke/stdin_to_bosh-lite.json"
	end	
end