# frozen_string_literal: true

RecordingStudio.configure do |config|
  # Registered delegated_type recordables (strings or classes)
  config.recordable_types = [ "Workspace", "Folder", "Page", "RecordingStudioVideo::Video" ]

  # Require each configured ActiveRecord type to call recording_studio_recordable.
  config.require_recordable_declarations = true

  # Shown in the shared default layout title fallback.
  config.app_name = "Addon Template" if config.respond_to?(:app_name=)

  # Actor resolver for events when no actor is explicitly supplied
  config.actor = -> { Current.actor }
  config.impersonator = -> { Current.impersonator }

  # Writes fail closed: missing authorize_write raises AuthorizationError;
  # missing actor raises ActorRequired. A signed-in User is not a write policy
  # for an existing root. Core 7 create_root_recording! authorizes before a
  # root exists, so a present actor may create that root. Later writes still
  # need Accessible :edit on the root. Access grant/bootstrap writes go through
  # Accessible's AccessCreationContext only when the recordable is
  # RecordingStudio::Access.
  config.authorize_write = lambda { |actor:, root_recording:, recordable:, **|
    if root_recording.nil?
      next actor.present?
    end

    if defined?(RecordingStudio::Access) && recordable.is_a?(RecordingStudio::Access)
      next true if RecordingStudioAccessible::AccessCreationContext.allowed?

      RecordingStudioAccessible.authorized?(
        actor: actor,
        recording: root_recording,
        role: :admin
      )
    else
      RecordingStudioAccessible.authorized?(
        actor: actor,
        recording: root_recording,
        role: :edit
      )
    end
  }

  # Emit ActiveSupport::Notifications events
  config.event_notifications_enabled = true

  # Idempotency behavior for log_event!
  config.idempotency_mode = :return_existing # or :raise

  # Recordable duplication strategy for revisions
  config.recordable_dup_strategy = :dup
end
