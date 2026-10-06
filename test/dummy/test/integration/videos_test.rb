# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class VideosTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  YOUTUBE_URL = "https://www.youtube.com/watch?v=jNQXAC9IVRw"

  setup do
    @user = User.find_or_create_by!(email: "video-ui@example.com") do |user|
      user.password = "Password"
      user.password_confirmation = "Password"
    end
    sign_in @user
    @workspace = Workspace.create!(name: "Video UI #{SecureRandom.hex(4)}")
    @root = RecordingStudio.root_recording_for(@workspace)
  end

  test "fields render the three inputs and a url error" do
    get new_video_path(workspace_id: @root.id)

    assert_response :success
    assert_includes response.body, "Title"
    assert_includes response.body, "Video URL"
    assert_includes response.body, "Description"
    assert_includes response.body, "Paste a link to a supported video, such as YouTube."
    assert_includes response.body, "video[title]"
    assert_includes response.body, "video[url]"
    assert_includes response.body, "video[description]"
    assert_includes response.body, "Cancel"
    assert_includes response.body, "Save"

    post videos_path, params: {
      workspace_id: @root.id,
      video: {
        title: "<script>alert(1)</script>",
        url: "https://vimeo.com/123456",
        description: "\"><img>"
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "That URL is not from a supported provider."
    assert_includes response.body, "&lt;script&gt;alert(1)&lt;/script&gt;"
    assert_includes response.body, "&quot;&gt;&lt;img&gt;"
    refute_includes response.body, "<script>alert(1)</script>"
    refute_includes response.body, "recording-studio-external-embed"
  end

  test "creating through the dummy with a bad url does not persist a recording" do
    assert_no_difference -> { RecordingStudio::Recording.where(recordable_type: "RecordingStudioVideo::Video").count } do
      assert_no_difference -> { RecordingStudioVideo::Video.count } do
        post videos_path, params: {
          workspace_id: @root.id,
          video: {
            title: "Nope",
            url: "https://vimeo.com/123456",
            description: "Skip"
          }
        }
      end
    end

    assert_response :unprocessable_entity
  end

  test "a supported video shows an escaped title description and player" do
    post videos_path, params: {
      workspace_id: @root.id,
      video: {
        title: "<script>alert(1)</script>",
        url: YOUTUBE_URL,
        description: "\"><b>zoo</b>"
      }
    }

    assert_redirected_to videos_path
    follow_redirect!

    assert_response :success
    assert_includes response.body, @workspace.name
    assert_includes response.body, "&lt;script&gt;alert(1)&lt;/script&gt;"
    assert_includes response.body, "&quot;&gt;&lt;b&gt;zoo&lt;/b&gt;"
    assert_includes response.body, "recording-studio-external-embed"
    refute_includes response.body, "<script>alert(1)</script>"

    recording = @root.videos.order(:created_at).last
    get edit_video_path(recording)

    assert_response :success
    assert_includes response.body, "Video URL"
    assert_includes response.body, "recording-studio-external-embed"
    assert_operator response.body.index("Video URL"), :<, response.body.index("recording-studio-external-embed")
  end
end
