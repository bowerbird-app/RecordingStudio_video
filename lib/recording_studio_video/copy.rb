# frozen_string_literal: true

require "i18n"

module RecordingStudioVideo
  # Rails I18n lookups for Video user-facing copy. Every call passes
  # `default:` English so a host locale without a fallback never shows
  # "translation missing". Keys live under `recording_studio.video.*`.
  #
  # Lib/playback keeps main's English literals. The helper maps known
  # English strings to locale keys at render.
  module Copy
    PREFIX = "recording_studio.video"

    ENTER_SUPPORTED_VIDEO_URL = "Enter a supported video URL."

    TITLE_LABEL = "Title"
    URL_LABEL = "Video URL"
    URL_HINT = "Paste a link to a supported video, such as YouTube."
    DESCRIPTION_LABEL = "Description"

    USER_MESSAGE_KEYS = {
      ENTER_SUPPORTED_VIDEO_URL => "errors.enter_supported_video_url"
    }.freeze

    module_function

    def t(key, **)
      I18n.t("#{PREFIX}.#{key}", **)
    end

    # Map known English validation messages to locale keys at render.
    # Unknown or already-translated values return unchanged (External Embed
    # provider messages pass through byte-for-byte).
    def user_message(message)
      return message if message.blank?

      english = message.to_s
      key = USER_MESSAGE_KEYS[english]
      key ? t(key, default: english) : english
    end

    def field_label(name, default:)
      t("fields.#{name}.label", default: default)
    end

    def field_hint(name, default:)
      return if default.nil?

      t("fields.#{name}.hint", default: default)
    end
  end
end
