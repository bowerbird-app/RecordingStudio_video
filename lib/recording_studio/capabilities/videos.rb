# frozen_string_literal: true

module RecordingStudio
  module Capabilities
    module Videos
      def self.to
        RecordingStudio::Capabilities.include_for(:videos)
      end

      def self.register!
        RecordingStudio.register_capability(
          :videos,
          recording_methods: RecordingMethods,
          source: "recording_studio_video",
          child_recordables: ["RecordingStudioVideo::Video"]
        )
      end

      module RecordingMethods
        def videos
          assert_capability!(:videos)
          child_recordings.of_type("RecordingStudioVideo::Video").order(:created_at)
        end
      end
    end
  end
end

RecordingStudio::Capabilities::Videos.register!
