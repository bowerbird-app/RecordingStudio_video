# frozen_string_literal: true

module DummyAccessibleAuth
  class << self
    def authentication_method
      :authenticate_user!
    end

    def current_actor_method
      :current_user
    end
  end
end

RecordingStudioAccessible.configure do |config|
  config.access_actor_types = [ "User" ]
end
