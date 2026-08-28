source 'https://rubygems.org'

gem 'aws-sdk-ses', '~> 1.40'
gem 'bootsnap', '~> 1.18.0', require: false
gem 'figaro', '~> 1.3.0'
gem 'jbuilder'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'

# Both are built from source on purpose: the deploy servers run a glibc older than 2.29, and the
# precompiled x86_64-linux gems that pg ships since 1.6 and nokogiri since 1.18 are linked against
# 2.29, so they load with "libm.so.6: version `GLIBC_2.29' not found". force_ruby_platform makes
# Bundler ignore those binaries and compile from source there, which is how both were installed
# before they started publishing Linux binaries. Needs bundler >= 2.3.18. nokogiri is listed here
# only for that flag - it is pulled in by Rails, not used directly. Drop both once the servers get
# a newer distribution; anything below glibc 2.29 is an out-of-support release and these two will
# not be the last gems to ship binaries it cannot load.
gem 'nokogiri', force_ruby_platform: true
gem 'pg', '~> 1.6.3', force_ruby_platform: true
gem 'rails', '~> 8.1.3'
gem 'recaptcha', '~> 5.21', require: 'recaptcha/rails'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.2.1' # For Punycode
# Ruby 3.4 demoted syslog from a default gem to a bundled one, so Bundler no longer puts it on the
# load path unless it is asked for. config/environments/production.rb logs through Syslog::Logger.
gem 'syslog'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.10.1'
end

group :development, :test do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'capybara'
  gem 'mina', '~> 1.2.4'
  gem 'pry'
  gem 'puma'
  gem 'unicorn'
  gem 'webmock'
end

group :test do
  # minitest 6 moved mocks and stubs out of the gem itself; test_helper requires
  # minitest/mock and the mailer test stubs a method with it.
  gem 'minitest-mock'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
