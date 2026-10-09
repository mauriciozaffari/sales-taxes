# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'stringio'
require 'tempfile'
require_relative '../lib/sales_taxes'

RSpec.configure do |config|
  config.order = :random
  config.disable_monkey_patching!
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
