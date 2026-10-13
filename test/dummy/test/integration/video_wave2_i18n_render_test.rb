# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

# Render-level literal-English asserts for wave 2 non-view copy.
# Does not rewrite existing tests to expect HOST strings.
class VideoWave2I18nRenderTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  HOST_ENTER_SUPPORTED = "HOST Enter a supported video URL."
  MAIN_ENTER_SUPPORTED = "Enter a supported video URL."

  setup do
    @user = User.find_or_create_by!(email: "wave2-i18n@example.com") do |record|
      record.password = "Password"
      record.password_confirmation = "Password"
    end
    @workspace = Workspace.create!(name: "Wave2 I18n #{SecureRandom.hex(4)}")
    @root = RecordingStudio.root_recording_for(@workspace)
    sign_in @user
    @backend_before = I18n.backend
    @load_path_before = I18n.load_path.dup
  end

  teardown do
    I18n.backend = @backend_before if @backend_before
    assert_equal @load_path_before, I18n.load_path
  end

  test "new video form renders literal english field labels and url hint" do
    get new_video_path(workspace_id: @root.id)

    assert_response :success
    assert_includes response.body, "Title"
    assert_includes response.body, "Video URL"
    assert_includes response.body, "Description"
    assert_includes response.body, "Paste a link to a supported video, such as YouTube."
    refute_includes response.body, "HOST Video URL"
    refute_includes response.body, "HOST Title"
    refute_includes response.body, "HOST Description"
    refute_includes response.body, "HOST Paste a link to a supported video, such as YouTube."
    refute_includes response.body, HOST_ENTER_SUPPORTED
  end

  test "unsupported provider error stays external embed english on the form" do
    post videos_path, params: {
      workspace_id: @root.id,
      video: {
        title: "Nope",
        url: "https://vimeo.com/123456",
        description: "Skip"
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "That URL is not from a supported provider."
    assert_includes response.body, "Video URL"
  end

  test "resolved non-video embed shows main english url error on the form" do
    with_gem_english_backend do
      post_not_video_form

      assert_response :unprocessable_entity
      assert_includes response.body, MAIN_ENTER_SUPPORTED
      assert_includes response.body, "Video URL"
      refute_includes response.body, HOST_ENTER_SUPPORTED
      assert_equal MAIN_ENTER_SUPPORTED,
                   RecordingStudioVideo::Copy.t("errors.url.enter_supported")
    end
  end

  test "resolved non-video embed shows boot-overridden host url error on the form" do
    assert_equal HOST_ENTER_SUPPORTED,
                 I18n.t("recording_studio.video.errors.url.enter_supported", raise: true)

    post_not_video_form

    assert_response :unprocessable_entity
    assert_select "p", text: HOST_ENTER_SUPPORTED
    assert_includes response.body, "Video URL"
    assert_equal HOST_ENTER_SUPPORTED,
                 RecordingStudioVideo::Copy.t("errors.url.enter_supported")
  end

  private

  def post_not_video_form
    provider = RecordingStudio::ExternalEmbed::Provider.define(:"gallery_#{SecureRandom.hex(2)}") do
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
  end

  def with_gem_english_backend
    previous_load_path = I18n.load_path.dup
    previous_backend = I18n.backend
    previous_locale = I18n.locale
    I18n.backend = I18n::Backend::Simple.new
    I18n.locale = :en
    begin
      I18n.t("recording_studio.video.errors.url.enter_supported", raise: true)
    rescue I18n::MissingTranslationData
      # expected before gem en.yml is loaded onto this fresh backend
    end
    I18n.backend.load_translations(
      File.expand_path("../../../../config/locales/en.yml", __dir__)
    )
    yield
  ensure
    I18n.backend = previous_backend
    I18n.locale = previous_locale
    assert_equal previous_load_path, I18n.load_path
  end
end
