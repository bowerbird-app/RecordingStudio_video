# frozen_string_literal: true

require "test_helper"
require "recording_studio_api"

# Hosts that load RecordingStudioApi used to NameError at boot when this gem
# called register_integrations! from the after_initialize initializer before
# the main autoloader could resolve RecordingStudioVideo::Video. They worked
# around it with an early require and/or Object.const_set(:Video, ...).
# Registration must wait for to_prepare and must not need those host hacks.
class VideoApiRegistrationBootTest < ActiveSupport::TestCase
  test "api registers from to_prepare without host Video require or const_set" do
    assert defined?(::RecordingStudioApi)
    refute Object.const_defined?(:Video, false)

    real_video = RecordingStudioVideo::Video
    RecordingStudioVideo.send(:remove_const, :Video)

    begin
      # Autoloader not ready: nested Video is missing. after_initialize must not
      # call register_integrations! (that NameErrors when RecordingStudioApi is loaded).
      after_initialize = RecordingStudioVideo::Engine.initializers.find do |entry|
        entry.name == "recording_studio_video.after_initialize"
      end
      after_initialize.block.call(Object.new)

      # Autoloader ready (to_prepare): the model constant is available without a
      # host require or top-level Video const_set.
      RecordingStudioVideo.const_set(:Video, real_video)
      RecordingStudioVideo.register_integrations!

      registration = RecordingStudioApi.recordable_registration_for("RecordingStudioVideo::Video")

      assert registration
      assert_equal %w[description title url], registration.writable_attributes
      assert_equal %w[description title url], registration.output_keys.sort
      assert_equal %w[canonical_url content_type provider], registration.fields.keys.sort
      assert_nothing_raised { RecordingStudioApi.configuration.validate! }
      refute Object.const_defined?(:Video, false)
    ensure
      RecordingStudioVideo.send(:remove_const, :Video) if RecordingStudioVideo.const_defined?(:Video, false)
      RecordingStudioVideo.const_set(:Video, real_video)
    end
  end
end
