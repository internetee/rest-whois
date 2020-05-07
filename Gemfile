source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'figaro', '~> 1.1.0'
gem 'jbuilder'
gem 'pg', '~> 1.0.0'
gem 'rails', '~> 6.0.0'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'sassc-rails'
gem 'simpleidn', '0.0.7' # For Punycode
gem 'uglifier'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :development, :test do
  gem 'pry'
  gem 'unicorn'

  gem 'capybara'
  gem 'capybara-webkit'
  gem 'mina', '~> 0.3.8'
  gem 'puma'
  gem 'webmock'
end

group :test do
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
