source 'https://rubygems.org'

# core
gem 'rails', '4.2.1'

# model related
gem 'pg', '~> 0.18.0'

# views
gem 'haml-rails', '~> 0.9.0'
gem 'recaptcha', '~> 0.4.0', require: 'recaptcha/rails'

# load env
gem 'figaro', '~> 1.1.0'

# monitors
gem 'newrelic_rpm', '~> 3.9.9.275'

group :development, :test do
  # debug
  gem 'pry', '~> 0.10.1'

  # dev tools
  gem 'unicorn'

  # dev tools
  gem 'spring',  '~> 1.3.3'
  gem 'rubocop', '~> 0.26.1'

  # improved errors
  gem 'better_errors',     '~> 2.0.0'
  gem 'binding_of_caller', '~> 0.7.2'

  # deploy
  gem 'mina', '~> 0.3.1' # for fast deployment
end
