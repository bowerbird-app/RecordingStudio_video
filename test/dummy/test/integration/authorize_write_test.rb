# frozen_string_literal: true

require "test_helper"

class AuthorizeWriteTest < ActiveSupport::TestCase
  test "dummy authorize_write is configured and is not actor presence" do
    initializer = File.read(Rails.root.join("config/initializers/recording_studio.rb"))

    assert_includes initializer, "config.authorize_write"
    assert_includes initializer, "RecordingStudioAccessible.authorized?"
    assert_includes initializer, "AccessCreationContext.allowed?"
    assert_includes initializer, "recordable.is_a?(RecordingStudio::Access)"
    refute_includes initializer, "target = recording || parent_recording || root_recording"
    refute_match(/authorize_write\s*=\s*->\(actor:, \*\*\) \{ actor\.is_a\?\(User\) && actor\.persisted\? \}/, initializer)
    refute_match(/authorize_write\s*=\s*->\(actor:, \*\*\) \{ actor\.present\? \}/, initializer)
    refute_includes initializer, "allow_unauthorized_writes = true"
  end

  test "dummy authorize_write requires Accessible edit on the root" do
    authorizer = RecordingStudio.configuration.authorize_write

    refute_nil authorizer

    actor = User.find_or_create_by!(email: "dummy-write-authorizer-#{SecureRandom.hex(4)}@example.com") do |record|
      record.password = "Password"
      record.password_confirmation = "Password"
    end
    workspace = Workspace.create!(name: "Write policy #{SecureRandom.hex(4)}")
    root_recording = RecordingStudio.root_recording_for(workspace)
    folder = Folder.new(name: "Write policy folder")

    refute authorizer.call(actor: nil, root_recording: root_recording, recordable: folder)
    refute authorizer.call(actor: actor, root_recording: root_recording, recordable: folder)

    grant_dummy_owner!(root_recording, actor: actor)

    assert authorizer.call(actor: actor, root_recording: root_recording, recordable: folder)
  end

  test "AccessCreationContext does not let a no-grant user create a Page" do
    actor = User.find_or_create_by!(email: "dummy-write-context-#{SecureRandom.hex(4)}@example.com") do |record|
      record.password = "Password"
      record.password_confirmation = "Password"
    end
    workspace = Workspace.create!(name: "Context page #{SecureRandom.hex(4)}")
    root_recording = RecordingStudio.root_recording_for(workspace)
    page = Page.new(title: "Context page")

    refute RecordingStudioAccessible.authorized?(actor: actor, recording: root_recording, role: :edit)

    previous_actor = Current.actor
    Current.actor = actor
    begin
      RecordingStudioAccessible::AccessCreationContext.allow do
        error = assert_raises(RecordingStudio::AuthorizationError) do
          RecordingStudio.record!(
            action: "created",
            recordable: page,
            root_recording: root_recording,
            parent_recording: root_recording,
            actor: actor
          )
        end
        assert_match(/denied by config.authorize_write/, error.message)
      end
    ensure
      Current.actor = previous_actor
    end
  end
end
