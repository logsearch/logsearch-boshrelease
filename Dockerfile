FROM dockerfile/ruby

RUN apt-get install curl -y
RUN bundle install #"2014-07-10"

VOLUME ["/workspace"]
WORKDIR /workspace