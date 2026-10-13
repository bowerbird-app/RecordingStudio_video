# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class VideoHostLocaleOverrideTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  HOST_URL_LABEL = "HOST Video URL"
  URL_LABEL_KEY = "recording_studio.video.fields.url.label"
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

  # Default dummy UI (no always-loaded host override under config/locales) shows
  # gem English for field labels.
  test "default dummy new video form shows gem english url label" do
    get new_video_path(workspace_id: @root.id)

    assert_response :success
    assert_includes response.body, "Video URL"
    refute_includes response.body, HOST_URL_LABEL
    assert_equal @load_path_before, I18n.load_path
  end

  # Test-only fixture on a fresh backend: I18n.t once to initialize, then
  # load_translations into that backend, assert HOST as a precondition, render.
  test "fresh-backend host fixture overrides gem english on url label" do
    assert File.exist?(FRESH_HOST_LOCALE), "expected test-only host override fixture at #{FRESH_HOST_LOCALE}"
    assert_includes File.read(FRESH_HOST_LOCALE), HOST_URL_LABEL

    I18n.backend = I18n::Backend::Simple.new
    I18n.t(URL_LABEL_KEY)
    I18n.backend.load_translations(FRESH_HOST_LOCALE.to_s)

    assert_equal @load_path_before, I18n.load_path
    assert_equal HOST_URL_LABEL, I18n.t(URL_LABEL_KEY),
                 "HOST string must win on the fresh backend before the page render"

    get new_video_path(workspace_id: @root.id)
    assert_response :success
    assert_includes response.body, HOST_URL_LABEL
    assert_includes response.body, "Title"
    assert_includes response.body, "Description"
  ensure
    I18n.backend = @backend_before if @backend_before
  end
end
