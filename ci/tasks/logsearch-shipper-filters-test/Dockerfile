FROM ruby:2.0

RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jre && \
  rm -rf /var/lib/apt/lists/*

RUN \
  git clone https://github.com/elastic/logstash.git /usr/local/logstash \
  && cd /usr/local/logstash \
  && rake bootstrap \
  && rake test:install-core \
  && rake test:install-default

ENTRYPOINT /bin/bash
