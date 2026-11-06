# frozen_string_literal: true

module DummyAccessibleGrants
  def dummy_write_actor
    @dummy_write_actor ||= User.find_or_create_by!(email: "dummy-writer@example.com") do |user|
      user.password = "Password"
      user.password_confirmation = "Password"
    end
  end

  def grant_dummy_owner!(recording, actor: dummy_write_actor)
    Current.actor = actor
    return recording if RecordingStudioAccessible.authorized?(actor: actor, recording: recording, role: :edit)

    result = RecordingStudioAccessible.bootstrap_owner_access!(recording: recording, actor: actor)
    raise result.error if result.failure?

    recording
  end
end
