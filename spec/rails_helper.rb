ENV['RAILS_ENV'] ||= 'test'
require_relative 'spec_helper'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.mock_with :rspec do |m|
    m.verify_partial_doubles = true
  end
  config.before(:each) do
    Recharge.delete_all
    Payment.delete_all
  end
end
