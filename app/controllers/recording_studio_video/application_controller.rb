# frozen_string_literal: true

module RecordingStudioVideo
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    recording_studio_layout { RecordingStudioVideo.configuration.layout }
  end
end
