# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class VideoHostLocaleOverrideTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  HOST_TITLE_LABEL = "HOST Title"
  HOST_URL_LABEL = "HOST Video URL"
  HOST_URL_HINT = "HOST Paste a link to a supported video, such as YouTube."
  HOST_DESCRIPTION_LABEL = "HOST Description"
  HOST_ENTER_SUPPORTED = "HOST Enter a supported video URL."
  MAIN_ENTER_SUPPORTED = "Enter a supported video URL."
  TITLE_LABEL_KEY = "recording_studio.video.fields.title.label"
  URL_LABEL_KEY = "recording_studio.video.fields.url.label"
  URL_HINT_KEY = "recording_studio.video.fields.url.hint"
  DESCRIPTION_LABEL_KEY = "recording_studio.video.fields.description.label"
  ENTER_SUPPORTED_KEY = "recording_studio.video.errors.url.enter_supported"
  BOOT_HOST_LOCALE = Rails.root.join("config/locales/recording_studio_video_boot_override.en.yml")
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

  # Always-loaded host override on packaged errors.url.enter_supported (only
  # shown after an invalid submit). /videos/new GET stays gem English.
  test "boot-loaded host override wins on enter_supported error" do
    assert File.exist?(BOOT_HOST_LOCALE), "expected boot override file at #{BOOT_HOST_LOCALE}"
    assert_includes File.read(BOOT_HOST_LOCALE), HOST_ENTER_SUPPORTED
    assert_includes I18n.load_path.map { |path| File.expand_path(path) },
                    File.expand_path(BOOT_HOST_LOCALE),
                    "boot override must already be on I18n.load_path"

    assert_equal HOST_ENTER_SUPPORTED, I18n.t(ENTER_SUPPORTED_KEY, raise: true)
    assert_equal @load_path_before, I18n.load_path

    get new_video_path(workspace_id: @root.id)

    assert_response :success
    assert_includes response.body, "Title"
    assert_includes response.body, "Video URL"
    assert_includes response.body, "Description"
    assert_includes response.body, "Paste a link to a supported video, such as YouTube."
    refute_includes response.body, HOST_ENTER_SUPPORTED
    refute_includes response.body, HOST_URL_LABEL
    assert_equal @load_path_before, I18n.load_path

    provider = gallery_provider(:gallery_boot_override)
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
    assert_select "p", text: HOST_ENTER_SUPPORTED
    assert_select "p", text: MAIN_ENTER_SUPPORTED, count: 0
    assert_equal @load_path_before, I18n.load_path
  end

  # Default dummy GET (boot override only affects enter_supported) shows gem
  # English for field labels and the URL hint.
  test "default dummy new video form shows gem english field copy" do
    get new_video_path(workspace_id: @root.id)

    assert_response :success
    assert_includes response.body, "Title"
    assert_includes response.body, "Video URL"
    assert_includes response.body, "Description"
    assert_includes response.body, "Paste a link to a supported video, such as YouTube."
    refute_includes response.body, HOST_TITLE_LABEL
    refute_includes response.body, HOST_URL_LABEL
    refute_includes response.body, HOST_URL_HINT
    refute_includes response.body, HOST_DESCRIPTION_LABEL
    assert_equal @load_path_before, I18n.load_path
  end

  # Test-only fixture on a fresh backend: I18n.t once to initialize, then
  # load_translations into that backend, assert HOST as a precondition, render.
  # Covers title, url label, url hint, description, and enter_supported so a
  # literal revert of NotVideo#message fails.
  test "fresh-backend host fixture overrides gem english field and error copy" do
    assert File.exist?(FRESH_HOST_LOCALE), "expected test-only host override fixture at #{FRESH_HOST_LOCALE}"
    fixture = File.read(FRESH_HOST_LOCALE)
    assert_includes fixture, HOST_TITLE_LABEL
    assert_includes fixture, HOST_URL_LABEL
    assert_includes fixture, HOST_URL_HINT
    assert_includes fixture, HOST_DESCRIPTION_LABEL
    assert_includes fixture, HOST_ENTER_SUPPORTED

    I18n.backend = I18n::Backend::Simple.new
    I18n.t(URL_LABEL_KEY)
    I18n.backend.load_translations(FRESH_HOST_LOCALE.to_s)

    assert_equal @load_path_before, I18n.load_path
    assert_equal HOST_TITLE_LABEL, I18n.t(TITLE_LABEL_KEY),
                 "HOST title label must win on the fresh backend before the page render"
    assert_equal HOST_URL_LABEL, I18n.t(URL_LABEL_KEY),
                 "HOST url label must win on the fresh backend before the page render"
    assert_equal HOST_URL_HINT, I18n.t(URL_HINT_KEY),
                 "HOST url hint must win on the fresh backend before the page render"
    assert_equal HOST_DESCRIPTION_LABEL, I18n.t(DESCRIPTION_LABEL_KEY),
                 "HOST description label must win on the fresh backend before the page render"
    assert_equal HOST_ENTER_SUPPORTED, I18n.t(ENTER_SUPPORTED_KEY),
                 "HOST enter_supported must win on the fresh backend before the page render"

    get new_video_path(workspace_id: @root.id)
    assert_response :success
    assert_includes response.body, HOST_TITLE_LABEL
    assert_includes response.body, HOST_URL_LABEL
    assert_includes response.body, HOST_URL_HINT
    assert_includes response.body, HOST_DESCRIPTION_LABEL

    provider = gallery_provider(:gallery_host_override)
    video = RecordingStudioVideo::Video.new(url: "https://gallery.test/items/photo1")
    RecordingStudio::ExternalEmbed.with_providers(provider) do
      refute video.valid?
      post videos_path, params: {
        workspace_id: @root.id,
        video: {
          title: "Gallery",
          url: "https://gallery.test/items/photo1",
          description: "Skip"
        }
      }
    end

    assert_equal [{ error: HOST_ENTER_SUPPORTED }], video.errors.details[:url]
    assert_includes video.errors.full_messages.join(" "), HOST_ENTER_SUPPORTED
    assert_response :unprocessable_entity
    assert_includes response.body, HOST_ENTER_SUPPORTED
  ensure
    I18n.backend = @backend_before if @backend_before
  end

  private

  def gallery_provider(name)
    RecordingStudio::ExternalEmbed::Provider.define(name) do
      host "gallery.test"
      label "Gallery"
      embed_host "gallery.test"
      embeds_as "https://gallery.test/embed/{id}"
      canonical "https://gallery.test/items/{id}"
      match(content_type: :image, aspect: Rational(1, 1)) do
        path %r{\A/items/(?<id>[A-Za-z0-9_-]{1,64})/?\z}
      end
    end
  end
end
