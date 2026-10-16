# frozen_string_literal: true

# Fake RecordingStudioAdmin::ScreensController for API boot tests only.
#
# recording_studio_api's engine registers a to_prepare hook that always
# `require_dependency "recording_studio_admin/screens_controller"`. This dummy
# does not install Recording Studio Admin (flatpack pin and surface area), so
# when RECORDING_STUDIO_VIDEO_LOAD_API=1 prepends this directory onto
# $LOAD_PATH in config/application.rb, this stub satisfies that require.
# It is not a real Admin screen and must not be used outside that boot path.
# See MIGRATION_NOTES.md.
module RecordingStudioAdmin
  class ScreensController < ActionController::Base
  end
end
