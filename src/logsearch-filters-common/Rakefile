require 'erb'

task :clean do
  mkdir_p "target"
  rm_rf "target/*"
end

desc "Builds filters & dashboards"
task :build => :clean do
  puts "===> Building ..."
  compile_erb 'src/logstash-filters/default.conf.erb', 'target/logstash-filters-default.conf'

  puts "===> Artifacts:"
  puts `tree target`
end

desc "Runs unit tests against filters & dashboards"
task :test => :build do
	puts "===> Testing ..."
  sh %Q[ JAVA_OPTS="$JAVA_OPTS -XX:+TieredCompilation -XX:TieredStopAtLevel=1" vendor/logstash/bin/logstash rspec $(find test -name *spec.rb) ]
end

def compile_erb(source_file, dest_file)
  if File.extname(source_file) == '.erb'
    output = ERB.new(File.read(source_file)).result(binding)
    File.write(dest_file, output)
  else
    cp source_file, dest_file
  end
end
