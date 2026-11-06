# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class VideosAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  YOUTUBE_URL = "https://www.youtube.com/watch?v=jNQXAC9IVRw"

  setup do
    @owner = User.find_or_create_by!(email: "video-owner@example.com") do |user|
      user.password = "Password"
      user.password_confirmation = "Password"
    end
    @outsider = User.find_or_create_by!(email: "video-outsider@example.com") do |user|
      user.password = "Password"
      user.password_confirmation = "Password"
    end
    @workspace = Workspace.create!(name: "Owned Videos #{SecureRandom.hex(4)}")
    @hidden_workspace = Workspace.create!(name: "Hidden Videos #{SecureRandom.hex(4)}")
    @root = RecordingStudio.root_recording_for(@workspace)
    @hidden_root = RecordingStudio.root_recording_for(@hidden_workspace)
    grant_dummy_owner!(@root, actor: @owner)
  end

  test "index lists only workspaces the actor can view" do
    sign_in @owner
    get videos_path

    assert_response :success
    assert_select "h2", text: @workspace.name
    assert_select "h2", text: @hidden_workspace.name, count: 0
  end

  test "new and create deny an actor without access to the parent" do
    sign_in @outsider

    get new_video_path(workspace_id: @root.id)
    assert_response :not_found

    sign_in @outsider
    assert_no_difference -> { RecordingStudio::Recording.where(recordable_type: "RecordingStudioVideo::Video").count } do
      post videos_path, params: {
        workspace_id: @root.id,
        video: {
          title: "Nope",
          url: YOUTUBE_URL,
          description: "Skip"
        }
      }
    end
    assert_response :not_found
  end

  test "edit and update deny an actor without access to the video" do
    sign_in @owner
    post videos_path, params: {
      workspace_id: @root.id,
      video: {
        title: "Zoo",
        url: YOUTUBE_URL,
        description: "Owned"
      }
    }
    assert_redirected_to videos_path
    recording = @root.videos.order(:created_at).last

    sign_out @owner
    sign_in @outsider

    get edit_video_path(recording)
    assert_response :not_found

    sign_in @outsider
    patch video_path(recording), params: {
      video: {
        title: "Stolen",
        url: YOUTUBE_URL,
        description: "No"
      }
    }
    assert_response :not_found
    assert_equal "Zoo", recording.reload.recordable.title
  end
end
