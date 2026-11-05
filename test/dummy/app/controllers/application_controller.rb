class ApplicationController < ActionController::Base
  include RecordingStudio::RootSwitchable::ControllerSupport

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  recording_studio_layout do
    "application" if devise_controller?
  end

  before_action :authenticate_user!
  before_action :set_current_actor

  private

  # Host layout helper kept for Devise and any caller that still names it.
  def application_layout
    return "application" if devise_controller?

    recording_studio_resolved_layout
  end

  def set_current_actor
    Current.actor = current_user
  end
end
