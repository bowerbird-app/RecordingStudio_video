# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

# Render-level literal-English asserts for wave 2 non-view copy.
# Does not rewrite existing tests to expect HOST strings.
class VideoWave2I18nRenderTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.find_or_create_by!(email: "wave2-i18n@example.com") do |record|
      record.password = "Password"
      record.password_confirmation = "Password"
    end
    @workspace = Workspace.create!(name: "Wave2 I18n #{SecureRandom.hex(4)}")
    @root = RecordingStudio.root_recording_for(@workspace)
    sign_in @user
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
    refute_includes response.body, "HOST Enter a supported video URL."
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

  # Boot override always loads HOST for enter_supported; GET /videos/new still
  # shows gem English labels (that key is absent until an invalid submit).
  test "resolved non-video embed shows boot-overridden host url error on the form" do
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
    assert_select "p", text: "HOST Enter a supported video URL."
    assert_includes response.body, "Video URL"
    assert_equal "HOST Enter a supported video URL.",
                 RecordingStudioVideo::Copy.t("errors.url.enter_supported")
  end
end
