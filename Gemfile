source 'https://rubygems.org'

gem 'aws-sdk-ses', '~> 1.40'
gem 'bootsnap', '~> 1.18.0', require: false
gem 'figaro', '~> 1.3.0'
gem 'jbuilder'
gem 'mimemagic', '~> 0.4.3'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'
# Built from source on purpose. The precompiled x86_64-linux gem that pg ships since 1.6 is
# linked against glibc 2.29, and the deploy servers are older than that, so the binary one loads
# with "libm.so.6: version `GLIBC_2.29' not found". Drop this once the servers are upgraded.
gem 'pg', '~> 1.6.3', force_ruby_platform: true
gem 'rails', '>= 6.0.3.1'
gem 'recaptcha', '~> 5.21', require: 'recaptcha/rails'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.2.1' # For Punycode
gem 'uglifier'

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
  gem 'selenium-webdriver'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end
