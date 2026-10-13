# frozen_string_literal: true

require "i18n"

module RecordingStudioVideo
  # Rails I18n lookups for Video user-facing copy. English ships only in
  # `config/locales/en.yml` under `recording_studio.video.*`. Call sites do
  # not pass English `default:` — a missing key behaves like main
  # (translation missing / raise-on-missing).
  #
  # Lib/playback keeps main's English literals. The helper maps known
  # English strings to locale keys at render.
  module Copy
    PREFIX = "recording_studio.video"

    ENTER_SUPPORTED_VIDEO_URL = "Enter a supported video URL."

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
      key ? t(key) : english
    end

    def field_label(name)
      t("fields.#{name}.label")
    end

    def field_hint(name)
      t("fields.#{name}.hint")
    end
  end
end
