# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "test_helper"
require_relative "dummy/config/environment"

require "rails/test_help"

class VideoRecordableTest < ActiveSupport::TestCase
  YOUTUBE_URL = "https://www.youtube.com/watch?v=jNQXAC9IVRw"
  SHORT_URL = "https://youtu.be/jNQXAC9IVRw"
  CANONICAL_URL = "https://www.youtube.com/watch?v=jNQXAC9IVRw"

  test "declarations validate and video is not a root" do
    assert RecordingStudio.validate_recordable_declarations!

    declaration = RecordingStudio.recordable_declaration_for("RecordingStudioVideo::Video")

    refute declaration.root?
    refute declaration.allowed_parent_types_provided
    assert_equal "Video", declaration.label
    assert_equal "Videos", declaration.plural_label
    assert_raises(NameError) { RecordingStudioVideo::Playback }
    assert_equal "video", RecordingStudioVideo::Video.model_name.param_key
    assert_equal "RecordingStudioVideo::Video", RecordingStudioVideo::Video.name
  end

  test "a workspace that includes videos can record many videos in created_at order" do
    root = workspace_root
    refute_respond_to root, :record_video

    first = record_video(root, YOUTUBE_URL, title: "First")
    second = record_video(root, SHORT_URL, title: "Second")

    assert_equal [first, second], root.videos.to_a
    assert_equal root.videos.map(&:created_at).sort, root.videos.map(&:created_at)
  end

  test "video cannot be recorded under a type that did not include the capability" do
    root = workspace_root
    folder = record_child(Folder.new(name: unique_name("Docs")), root, root)

    error = assert_raises(RecordingStudio::InvalidParent) do
      root.record(RecordingStudioVideo::Video, parent_recording: folder) do |video|
        video.url = YOUTUBE_URL
      end
    end

    assert_equal "RecordingStudioVideo::Video cannot be recorded under Folder", error.message
  end

  test "video cannot be a root recording" do
    video = RecordingStudioVideo::Video.create!(url: YOUTUBE_URL, title: "Launch")

    assert_raises(RecordingStudio::RootNotAllowed) do
      RecordingStudio.root_recording_for(video)
    end
  end

  test "title url and description are stored from the entered text" do
    recording = record_video(
      workspace_root,
      "  #{SHORT_URL}  ",
      title: "  Me at the zoo  ",
      description: "  "
    )
    video = recording.recordable

    assert_equal "Me at the zoo", video.title
    assert_equal SHORT_URL, video.url
    assert_nil video.description
    assert_nil video.summary
    assert_equal "youtube", video.provider
    assert_equal CANONICAL_URL, video.canonical_url
    assert_equal "video", video.content_type
  end

  test "a blank url is invalid" do
    video = RecordingStudioVideo::Video.new(url: "  ")

    refute video.valid?
    assert_includes video.errors[:url], "can't be blank"
  end

  test "an unsupported host is invalid with the external embed message" do
    video = RecordingStudioVideo::Video.new(url: "https://vimeo.com/123456")

    refute video.valid?
    assert_equal ["That URL is not from a supported provider."], video.errors[:url]
  end

  test "a malformed youtube url is invalid with the external embed message" do
    video = RecordingStudioVideo::Video.new(url: "https://www.youtube.com/watch?v=short")

    refute video.valid?
    assert_equal ["That URL is missing a valid id."], video.errors[:url]
  end

  test "a supported youtube url is valid" do
    video = RecordingStudioVideo::Video.new(
      title: "Launch",
      url: YOUTUBE_URL,
      description: "Teaser"
    )

    assert video.valid?
    assert_empty video.errors[:url]
  end

  test "a resolved non-video embed is invalid" do
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

    video = RecordingStudioVideo::Video.new(url: "https://gallery.test/items/photo1")
    RecordingStudio::ExternalEmbed.with_providers(provider) do
      refute video.valid?
    end

    assert_equal ["Enter a supported video URL."], video.errors[:url]
  end

  test "provider facts are derived and are not columns" do
    video = RecordingStudioVideo::Video.new(url: SHORT_URL)
    columns = RecordingStudioVideo::Video.column_names

    assert video.valid?
    assert_equal %w[created_at description id title url], columns.sort
    %w[provider external_id embed_url aspect_ratio canonical_url content_type updated_at].each do |name|
      refute_includes columns, name
    end
    assert_equal "youtube", video.provider
    assert_equal CANONICAL_URL, video.canonical_url
    assert_equal "video", video.content_type
  end

  test "api registration does nothing unless recording studio api is loaded" do
    refute defined?(::RecordingStudioApi)
    assert_nil RecordingStudioVideo::Api.register!
  end

  private

  def workspace_root
    RecordingStudio.root_recording_for(Workspace.create!(name: unique_name("Video Workspace")))
  end

  def record_video(root, url, title: "Launch", description: "Teaser")
    root.record(RecordingStudioVideo::Video, parent_recording: root) do |video|
      video.title = title
      video.url = url
      video.description = description
    end
  end

  def record_child(recordable, root_recording, parent_recording)
    RecordingStudio.record!(
      action: "created",
      recordable: recordable,
      root_recording: root_recording,
      parent_recording: parent_recording
    ).recording
  end

  def unique_name(prefix)
    "#{prefix} #{SecureRandom.hex(4)}"
  end
end
