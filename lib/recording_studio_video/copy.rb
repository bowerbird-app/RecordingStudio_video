# frozen_string_literal: true

require "i18n"

module RecordingStudioVideo
  # Rails I18n lookups for Video user-facing copy. English ships only in
  # `config/locales/en.yml` under `recording_studio.video.*`. Call sites do
  # not pass English `default:` — a missing key behaves like main
  # (translation missing / raise-on-missing).
  module Copy
    PREFIX = "recording_studio.video"

    module_function

    def t(key, **)
      I18n.t("#{PREFIX}.#{key}", **)
    end

    def field_label(name)
      t("fields.#{name}.label")
    end

    def field_hint(name)
      t("fields.#{name}.hint")
    end
  end
end
