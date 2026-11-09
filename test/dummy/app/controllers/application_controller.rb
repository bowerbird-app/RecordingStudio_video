class ApplicationController < ActionController::Base
  include RecordingStudio::RootSwitchable::ControllerSupport
  include RecordingStudioAccessible::ControllerAuth

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  recording_studio_layout do
    "application" if devise_controller?
  end

  recording_studio_auth(
    config: -> { DummyAccessibleAuth },
    prefix: :dummy,
    set_current_actor_method: :set_current_actor,
    actor_resolution: :method_only,
    unless: :devise_controller?
  )

  private

  # Host layout helper kept for Devise and any caller that still names it.
  def application_layout
    return "application" if devise_controller?

    recording_studio_resolved_layout
  end

  def accessible_workspace_roots(role:)
    RecordingStudioAccessible.root_recordings_for(actor: current_user, minimum_role: role)
      .select { |root| root.recordable.is_a?(Workspace) }
      .sort_by { |root| root.recordable.name.to_s }
  end

  def require_accessible_recording!(recording, role:)
    raise ActiveRecord::RecordNotFound if recording.blank?
    unless RecordingStudioAccessible.authorized?(actor: current_user, recording: recording, role: role)
      raise ActiveRecord::RecordNotFound
    end

    recording
  end
end
