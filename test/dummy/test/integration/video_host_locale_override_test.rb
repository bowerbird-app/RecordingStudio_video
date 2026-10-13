# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class VideoHostLocaleOverrideTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  HOST_TITLE_LABEL = "HOST Title"
  HOST_URL_LABEL = "HOST Video URL"
  HOST_URL_HINT = "HOST Paste a link to a supported video, such as YouTube."
  HOST_DESCRIPTION_LABEL = "HOST Description"
  HOST_BOOT_MARK = "HOST boot override seen"
  MAIN_BOOT_MARK = "video-boot-probe"
  BOOT_MARK_KEY = "recording_studio.video.probes.boot_mark"
  TITLE_LABEL_KEY = "recording_studio.video.fields.title.label"
  URL_LABEL_KEY = "recording_studio.video.fields.url.label"
  URL_HINT_KEY = "recording_studio.video.fields.url.hint"
  DESCRIPTION_LABEL_KEY = "recording_studio.video.fields.description.label"
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

  # Always-loaded host override on rarely shown probes.boot_mark. Normal
  # /videos/new stays gem English; the test-only probe route shows HOST.
  test "boot-loaded host override wins on probe boot mark" do
    assert File.exist?(BOOT_HOST_LOCALE), "expected boot override file at #{BOOT_HOST_LOCALE}"
    assert_includes File.read(BOOT_HOST_LOCALE), HOST_BOOT_MARK

    assert_equal HOST_BOOT_MARK, I18n.t(BOOT_MARK_KEY, raise: true)
    assert_equal @load_path_before, I18n.load_path

    get new_video_path(workspace_id: @root.id)

    assert_response :success
    assert_includes response.body, "Title"
    assert_includes response.body, "Video URL"
    assert_includes response.body, "Description"
    assert_includes response.body, "Paste a link to a supported video, such as YouTube."
    refute_includes response.body, HOST_BOOT_MARK
    refute_includes response.body, HOST_URL_LABEL
    assert_equal @load_path_before, I18n.load_path

    get video_i18n_probe_path

    assert_response :success
    assert_includes response.body, HOST_BOOT_MARK
    refute_includes response.body, MAIN_BOOT_MARK
    assert_equal @load_path_before, I18n.load_path
  end

  # Default dummy UI (boot override is only on probes.boot_mark) shows gem
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
  # Covers title, url label, url hint, and description so a literal revert fails.
  test "fresh-backend host fixture overrides gem english field copy" do
    assert File.exist?(FRESH_HOST_LOCALE), "expected test-only host override fixture at #{FRESH_HOST_LOCALE}"
    fixture = File.read(FRESH_HOST_LOCALE)
    assert_includes fixture, HOST_TITLE_LABEL
    assert_includes fixture, HOST_URL_LABEL
    assert_includes fixture, HOST_URL_HINT
    assert_includes fixture, HOST_DESCRIPTION_LABEL

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

    get new_video_path(workspace_id: @root.id)
    assert_response :success
    assert_includes response.body, HOST_TITLE_LABEL
    assert_includes response.body, HOST_URL_LABEL
    assert_includes response.body, HOST_URL_HINT
    assert_includes response.body, HOST_DESCRIPTION_LABEL
  ensure
    I18n.backend = @backend_before if @backend_before
  end
end
