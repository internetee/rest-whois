source 'https://rubygems.org'

gem 'jbuilder'
gem 'pg', '~> 0.19.0'
gem 'rails', '~> 4.2.7.1'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'simpleidn', '0.0.7' # For Punycode
gem 'SyslogLogger', '2.0', require: 'syslog/logger'
gem 'sass-rails'
gem 'uglifier'
gem 'figaro', '~> 1.1.0'

group :development do
  gem 'puma'
end

group :development, :test do
  gem 'pry'
  gem 'rubocop'
  gem 'unicorn'

  gem 'capybara'
  gem 'mina', '~> 0.3.8'
  gem 'webmock'
end

group :test do
  gem 'simplecov', require: false
end
