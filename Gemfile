source 'https://rubygems.org'

gem 'aws-sdk-ses', '~> 1.40'
gem 'bootsnap', '~> 1.18.0', require: false
gem 'figaro', '~> 1.3.0'
gem 'jbuilder'
gem 'mimemagic', '~> 0.4.3'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'
# Held on 1.5.x deliberately. 1.6.0 is the first release that publishes an x86_64-linux binary,
# and it is linked against glibc 2.29, which is newer than the deploy servers: the binary loads
# with "libm.so.6: version `GLIBC_2.29' not found". 1.5.x has no Linux binary at all, so it is
# always compiled from source there. The clean way back to 1.6.x is a newer distribution on the
# servers - or, as a stopgap, Bundler >= 2.3.18 on them plus force_ruby_platform on this line,
# which the Bundler currently installed there is too old to understand.
gem 'pg', '~> 1.5.9'
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
