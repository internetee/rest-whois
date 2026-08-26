ARG RUBY_VERSION=3.4.9
FROM ruby:${RUBY_VERSION}-bookworm

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libpq-dev \
    nodejs \
    netcat-openbsd \
    curl \
    imagemagick \
    shared-mime-info \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 3000
