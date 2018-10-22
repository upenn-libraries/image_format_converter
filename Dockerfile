FROM ruby:2.5-slim

MAINTAINER katherly@upenn.edu

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  imagemagick

RUN mkdir /mm_source

RUN mkdir /mm_converted

RUN mkdir /usr/src/app

ADD . /usr/src/app/

WORKDIR /usr/src/app/

RUN bundle install

CMD ["bash", "-c", "while [ 1 ]; do sleep 10000; done"]
