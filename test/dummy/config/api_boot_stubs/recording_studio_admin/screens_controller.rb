# frozen_string_literal: true

# Minimal stub so RecordingStudioApi's to_prepare can boot in this dummy
# without installing RecordingStudio Admin. Only used when
# RECORDING_STUDIO_VIDEO_LOAD_API=1 prepends this directory onto $LOAD_PATH.
module RecordingStudioAdmin
  class ScreensController < ActionController::Base
  end
end
