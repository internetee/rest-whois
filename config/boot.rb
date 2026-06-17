ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# concurrent-ruby >= 1.3.5 dropped its implicit `require "logger"`, which
# ActiveSupport 6.1 relies on. Load it early so Rails boots on Ruby 3.4.
require 'logger'

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
