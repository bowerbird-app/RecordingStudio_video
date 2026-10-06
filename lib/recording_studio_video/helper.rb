# frozen_string_literal: true

module RecordingStudioVideo
  module Helper
    FIELD_COMPONENTS = {
      text: "FlatPack::TextInput::Component",
      url: "FlatPack::UrlInput::Component",
      textarea: "FlatPack::TextArea::Component"
    }.freeze
    private_constant :FIELD_COMPONENTS

    def recording_studio_video_player(subject)
      video = video_subject(subject)
      return "".html_safe unless video

      result = Playback.accept(video.url)
      return "".html_safe unless result.is_a?(RecordingStudio::ExternalEmbed::Embed)

      recording_studio_external_embed(result)
    end

    def recording_studio_video_fields(video)
      safe_join(Video::WRITABLE.map { |name| video_field(video, name) })
    end

    private

    def video_subject(subject)
      return subject if subject.is_a?(Video)
      return unless subject.is_a?(RecordingStudio::Recording)

      recordable = subject.recordable
      recordable if recordable.is_a?(Video)
    end

    def video_field(video, name)
      spec = FIELDS.fetch(name)
      render FIELD_COMPONENTS.fetch(spec.fetch(:input)).constantize.new(
        name: "#{video.model_name.param_key}[#{name}]",
        value: video.public_send(name),
        label: spec.fetch(:label),
        help_text: spec[:hint],
        error: video_field_error(video, name)
      )
    end

    def video_field_error(video, name)
      return unless name == :url

      messages = video.errors[:url]
      messages.join(", ") if messages.present?
    end
  end
end
