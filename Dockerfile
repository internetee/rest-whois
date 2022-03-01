FROM ruby:3.0.3
MAINTAINER maciej.szlosarczyk@internet.ee

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs \
    npm 
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 3000
