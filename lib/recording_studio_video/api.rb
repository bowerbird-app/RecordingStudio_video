# frozen_string_literal: true

module RecordingStudioVideo
  module Api
    def self.register!
      return unless defined?(::RecordingStudioApi)
      return if RecordingStudioApi.recordable_registration_for(Video.name)

      RecordingStudioApi.register_recordable_type_api(
        Video.name,
        serializer: serializer,
        output_keys: Video::WRITABLE,
        writable_attributes: Video::WRITABLE,
        fields: derived_fields
      )
    end

    def self.derived_fields
      Video::DERIVED.index_with do |name|
        {
          resolver: ->(context) { context.recordable.public_send(name) },
          include: true,
          openapi: { type: "string", nullable: true }
        }
      end
    end

    def self.serializer
      lambda do |video, **|
        Video::WRITABLE.index_with { |name| video.public_send(name) }
      end
    end
    private_class_method :serializer
  end
end
