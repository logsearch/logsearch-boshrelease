## How to remove gems from logstash

### 1. Download logstash plugins with plugins bundle

```
wget https://download.elastic.co/logstash/logstash/logstash-all-plugins-2.3.3.tar.gz
tar -xzf logstash-all-plugins-2.3.3.tar.gz
cd logstash-2.3.3
```

### 2. Delete the following gems from `Gemfile`
```
gem "logstash-input-wmi" # licensing issues with dependency
gem "logstash-output-zookeeper" # licensing issues with dependency
```

### 3. Delete the code we don't want in the tarball
```
rm -rf vendor/bundle/jruby/1.9/gems/jruby-win32ole*
rm -rf vendor/bundle/jruby/1.9/gems/slyphon-zookeeper_jar*
```

### 4. Execute logstash so bundle can update the lock file

```
bin/logstash
```

### 5. Create the new tarball

```
cd ..
tar -czf logstash-2.3.3-patched.tar.gz logstash-2.3.3/
```
