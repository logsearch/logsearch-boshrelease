FROM dockerfile/ruby

RUN mkdir -p /workspace
WORKDIR /workspace

ADD Gemfile /workspace/Gemfile
ADD Gemfile.lock /workspace/Gemfile.lock
RUN bundle install

VOLUME ["/workspace"]