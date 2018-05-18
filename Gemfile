source 'https://rubygems.org'

# core
gem 'rails', '~> 4.2.7.1'
gem 'simpleidn', '0.0.7' # For punycode

# model related
gem 'pg', '~> 0.19.0'

#logger
gem 'SyslogLogger', '2.0', require: 'syslog/logger'

# views
gem 'recaptcha', '~> 1.1.0', require: 'recaptcha/rails'
gem 'jbuilder' # For cleaner JSON views

# load env
gem 'figaro', '~> 1.1.0'

group :development, :test do
  # debug
  gem 'pry', '~> 0.10.1'

  # dev tools
  gem 'unicorn'
  gem 'spring',  '~> 1.3.3'
  gem 'rubocop'

  gem 'webmock'
  gem 'capybara'

  # deploy
  gem 'mina', '~> 0.3.8' # for fast deployment
end
