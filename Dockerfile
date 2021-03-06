FROM internetee/ruby:2.7
MAINTAINER maciej.szlosarczyk@internet.ee

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 3000
