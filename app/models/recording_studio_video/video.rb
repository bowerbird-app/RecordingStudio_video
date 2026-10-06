# frozen_string_literal: true

module RecordingStudioVideo
  class Video < ApplicationRecord
    self.table_name = "recording_studio_videos"

    def self.model_name
      ActiveModel::Name.new(self, nil, "Video")
    end

    WRITABLE = %i[title url description].freeze
    DERIVED = %i[provider canonical_url content_type].freeze
    NOT_VIDEO_MESSAGE = "Enter a supported video URL."
    private_constant :NOT_VIDEO_MESSAGE

    recording_studio_recordable label: "Video",
                                plural_label: "Videos",
                                root: false

    before_validation :normalize_text

    validates :url, presence: true
    validate :url_must_be_video

    def summary
      description
    end

    DERIVED.each do |name|
      define_method(name) { derived_string(name) }
    end

    private

    def accepted
      current = url
      return @accepted if defined?(@accepted_url) && @accepted_url == current

      @accepted_url = current
      @accepted = Playback.accept(current)
    end

    def derived_string(name)
      result = accepted
      return unless result.is_a?(RecordingStudio::ExternalEmbed::Embed)

      result.public_send(name)&.to_s
    end

    def normalize_text
      self.title = blank_to_nil(title)
      self.description = blank_to_nil(description)
      self.url = url.strip if url.is_a?(String)
    end

    def blank_to_nil(value)
      return if value.nil?

      value.to_s.strip.presence
    end

    def url_must_be_video
      return if url.blank?

      result = accepted
      return if result.is_a?(RecordingStudio::ExternalEmbed::Embed)

      errors.add(:url, url_message(result))
    end

    def url_message(result)
      return result.message if result.is_a?(RecordingStudio::ExternalEmbed::Unresolved)

      NOT_VIDEO_MESSAGE
    end
  end

  raise ArgumentError, "FIELDS keys must equal WRITABLE" unless FIELDS.keys == Video::WRITABLE
end
