# frozen_string_literal: true

module RecordingStudioVideo
  module Api
    def self.register!
      return unless defined?(::RecordingStudioApi)
      return if ::RecordingStudioApi.recordable_registration_for(::RecordingStudioVideo::Video.name)

      ::RecordingStudioApi.register_recordable_type_api(
        ::RecordingStudioVideo::Video.name,
        serializer: serializer,
        output_keys: ::RecordingStudioVideo::Video::WRITABLE,
        writable_attributes: ::RecordingStudioVideo::Video::WRITABLE,
        fields: derived_fields
      )
    end

    def self.derived_fields
      ::RecordingStudioVideo::Video::DERIVED.index_with do |name|
        {
          resolver: ->(context) { context.recordable.public_send(name) },
          include: true,
          openapi: { type: "string", nullable: true }
        }
      end
    end

    def self.serializer
      lambda do |video, **|
        ::RecordingStudioVideo::Video::WRITABLE.index_with { |name| video.public_send(name) }
      end
    end
    private_class_method :serializer
  end
end
