# frozen_string_literal: true

module RecordingStudioVideo
  # Unresolved accepts only its three catalog reasons. A resolved embed of any
  # other content type comes back as NOT_VIDEO so callers can use one sentence.
  module Playback
    CONTENT_TYPE = :video
    NOT_VIDEO = Object.new
    private_constant :CONTENT_TYPE, :NOT_VIDEO

    def self.accept(url)
      result = RecordingStudio::ExternalEmbed.resolve(url)
      return result if video?(result)
      return result if result.is_a?(RecordingStudio::ExternalEmbed::Unresolved)

      NOT_VIDEO
    end

    def self.video?(result)
      result.is_a?(RecordingStudio::ExternalEmbed::Embed) && result.content_type == CONTENT_TYPE
    end
    private_class_method :video?
  end
  private_constant :Playback
end
