# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require_relative "../../support/dummy_accessible_grants"

ActionController::Base.allow_forgery_protection = false

class ActiveSupport::TestCase
  include DummyAccessibleGrants
end

class ActionDispatch::IntegrationTest
  include DummyAccessibleGrants
end
