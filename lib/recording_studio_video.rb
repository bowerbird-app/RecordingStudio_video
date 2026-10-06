# frozen_string_literal: true

require "recording_studio"
require "recording_studio_video/version"
require "recording_studio_video/engine"
require "recording_studio_video/configuration"
require "recording_studio_video/capabilities/example"

module RecordingStudioVideo
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
  end
end
