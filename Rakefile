require 'rspec/core/rake_task'

desc "Here should be an integration test"
RSpec::Core::RakeTask.new(:spec) do |t, task_args|
  ENV["LC_ALL"] = "en_US.UTF-8"
  t.pattern = "spec/release/deployment_spec.rb"
  t.rspec_opts = "--format documentation"
end

