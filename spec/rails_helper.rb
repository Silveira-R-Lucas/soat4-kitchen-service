require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/config/'
  minimum_coverage 80
end

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'mock_redis'
require 'sidekiq/testing'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:each) do
    stub_const("REDIS", MockRedis.new)
    Sidekiq::Worker.clear_all
  end

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
