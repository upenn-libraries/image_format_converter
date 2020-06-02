FROM ruby:2.5-slim

RUN apt update && apt install -y --no-install-recommends \
  build-essential \
  git \
  imagemagick

COPY . /usr/src/app/

WORKDIR /usr/src/app/

RUN bundle install

CMD ["bash", "-c", "while [ 1 ]; do sleep 10000; done"]
