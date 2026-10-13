# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class VideoHostLocaleOverrideTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  HOST_NOT_VIDEO = "HOST Enter a supported video URL."
  HOST_URL_LABEL = "HOST Video URL"
  NOT_VIDEO_KEY = "recording_studio.video.errors.enter_supported_video_url"
  URL_LABEL_KEY = "recording_studio.video.fields.url.label"
  BOOT_HOST_LOCALE = Rails.root.join("config/locales/recording_studio_video_host.en.yml")
  FRESH_HOST_LOCALE = Rails.root.join("test/locales/video_host_override.en.yml")

  setup do
    @load_path_before = I18n.load_path.dup
    @backend_before = I18n.backend
    @user = User.find_or_create_by!(email: "host-override@example.com") do |record|
      record.password = "Password"
      record.password_confirmation = "Password"
    end
    @workspace = Workspace.create!(name: "Host Override #{SecureRandom.hex(4)}")
    @root = RecordingStudio.root_recording_for(@workspace)
    sign_in @user
  end

  teardown do
    I18n.backend = @backend_before if @backend_before
    assert_equal @load_path_before, I18n.load_path,
                 "test must not leave I18n.load_path modified"
  end

  # Real-boot-order guard: host file under config/locales must win without any
  # test-time load_path mutation. Not-video copy is only shown after a resolved
  # non-video embed fails validation.
  test "host locale override for recording_studio.video wins on boot order" do
    assert File.exist?(BOOT_HOST_LOCALE)
    assert_includes File.read(BOOT_HOST_LOCALE), HOST_NOT_VIDEO
    assert_equal HOST_NOT_VIDEO, I18n.t(NOT_VIDEO_KEY)
    assert_equal @load_path_before, I18n.load_path,
                 "boot-order test must not mutate I18n.load_path"

    provider = RecordingStudio::ExternalEmbed::Provider.define(:gallery) do
      host "gallery.test"
      label "Gallery"
      embed_host "gallery.test"
      embeds_as "https://gallery.test/embed/{id}"
      canonical "https://gallery.test/items/{id}"
      match(content_type: :image, aspect: Rational(1, 1)) do
        path %r{\A/items/(?<id>[A-Za-z0-9_-]{1,64})/?\z}
      end
    end

    RecordingStudio::ExternalEmbed.with_providers(provider) do
      post videos_path, params: {
        workspace_id: @root.id,
        video: {
          title: "Gallery",
          url: "https://gallery.test/items/photo1",
          description: "Skip"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, HOST_NOT_VIDEO
    assert_includes response.body, "Video URL"
    refute_includes response.body, HOST_URL_LABEL
  end

  # Test-only fixture applied via backend.load_translations(file) on top of the
  # already-initialized backend — never mutates I18n.load_path.
  test "fresh-backend last-file-wins host fixture overrides gem english on url label" do
    assert File.exist?(FRESH_HOST_LOCALE), "expected test-only host override fixture at #{FRESH_HOST_LOCALE}"
    assert_includes File.read(FRESH_HOST_LOCALE), HOST_URL_LABEL

    snapshot = i18n_backend_translations_snapshot
    I18n.t(URL_LABEL_KEY)
    I18n.backend.load_translations(FRESH_HOST_LOCALE.to_s)

    assert_equal @load_path_before, I18n.load_path
    assert_equal HOST_URL_LABEL, I18n.t(URL_LABEL_KEY)
    assert_equal HOST_NOT_VIDEO, I18n.t(NOT_VIDEO_KEY)

    get new_video_path(workspace_id: @root.id)
    assert_response :success
    assert_includes response.body, HOST_URL_LABEL
    assert_includes response.body, "Title"
    assert_includes response.body, "Description"
  ensure
    restore_i18n_backend_translations(snapshot) if snapshot
  end

  private

  def i18n_backend_translations_snapshot
    backend = I18n.backend
    backend.send(:init_translations) unless backend.initialized?
    translations =
      if backend.respond_to?(:translations)
        backend.translations
      else
        backend.instance_variable_get(:@translations)
      end
    return unless translations

    deep_plain_copy(translations)
  end

  def restore_i18n_backend_translations(snapshot)
    backend = I18n.backend
    backend.instance_variable_set(:@translations, snapshot)
    backend.instance_variable_set(:@initialized, true) if backend.instance_variable_defined?(:@initialized)
  end

  def deep_plain_copy(value)
    case value
    when Hash
      value.each_with_object({}) { |(key, child), result| result[key] = deep_plain_copy(child) }
    when Array
      value.map { |child| deep_plain_copy(child) }
    else
      value
    end
  end
end
