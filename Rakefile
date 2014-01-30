require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

desc "Creates, uploads and deploys release.  Useful when developing a release"
task :create_and_deploy_release do
	sh "bosh create release --force && bosh -n upload release && bosh -n deploy"
end