# frozen_string_literal: true

module RecordingStudioVideo
  module Playback
    CONTENT_TYPE = :video

    class NotVideo
      def message
        "Enter a supported video URL."
      end
    end
    private_constant :CONTENT_TYPE, :NotVideo

    def self.accept(url)
      result = RecordingStudio::ExternalEmbed.resolve(url)
      return result if video?(result)
      return result if result.is_a?(RecordingStudio::ExternalEmbed::Unresolved)

      NotVideo.new
    end

    def self.video?(result)
      result.is_a?(RecordingStudio::ExternalEmbed::Embed) && result.content_type == CONTENT_TYPE
    end
    private_class_method :video?
  end
  private_constant :Playback
end
