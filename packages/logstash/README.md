## How to remove gems from logstash

### 1. Download logstash plugins with plugins bundle

```
wget https://download.elastic.co/logstash/logstash/logstash-all-plugins-2.3.1.tar.gz
tar -xzf logstash-all-plugins-2.3.1.tar.gz
cd logstash-2.3.1
```

### 2. Delete the following gems from `Gemfile`
* gem "logstash-input-wmi" # licensing issues

### 3. Execute logstash so bundle can update the lock file

```
bin/logstash
```

### 4. Create the new tarball

```
cd ..
tar -czf logstash-2.3.1-patched.tar.gz logstash-2.3.1/
```
