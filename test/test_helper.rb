require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/power_assert'
require 'minitest/mock'

class ActiveSupport::TestCase
  include Minitest::PowerAssert::Assertions

  fixtures :all
end
