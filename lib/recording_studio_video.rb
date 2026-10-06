# frozen_string_literal: true

require "recording_studio"
require "recording_studio_external_embed"
require "flat_pack"
require "recording_studio_video/version"
require "recording_studio_video/engine"
require "recording_studio_video/configuration"
require "recording_studio_video/capabilities/example"
require "recording_studio/capabilities/videos"
require "recording_studio_video/playback"
require "recording_studio_video/api"
require "recording_studio_video/helper"

module RecordingStudioVideo
  FIELDS = {
    title: { label: "Title", input: :text },
    url: {
      label: "Video URL",
      input: :url,
      hint: "Paste a link to a supported video, such as YouTube."
    },
    description: { label: "Description", input: :textarea }
  }.freeze
  private_constant :FIELDS

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end

    def register_integrations!
      RecordingStudio::Capabilities::Videos.register!
      Api.register!
    end
  end
end
