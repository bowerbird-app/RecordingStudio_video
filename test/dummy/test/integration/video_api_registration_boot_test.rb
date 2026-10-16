# frozen_string_literal: true

require "test_helper"

# Hosts that load RecordingStudioApi used to NameError at boot when this gem
# called register_integrations! from the after_initialize initializer before
# the main autoloader could resolve RecordingStudioVideo::Video. They worked
# around it with an early require and/or Object.const_set(:Video, ...).
# Registration must wait for to_prepare and must not need those host hacks.
class VideoApiRegistrationBootTest < ActiveSupport::TestCase
  test "api registers from to_prepare without host Video require or const_set" do
    refute Object.const_defined?(:Video, false)

    real_video = RecordingStudioVideo::Video
    registered = nil
    previous_api_defined = Object.const_defined?(:RecordingStudioApi, false)
    previous_api = Object.const_get(:RecordingStudioApi) if previous_api_defined

    fake_api = Module.new do
      define_singleton_method(:recordable_registration_for) { |_| nil }
      define_singleton_method(:register_recordable_type_api) do |type_name, **kwargs|
        registered = {
          name: type_name,
          output_keys: kwargs[:output_keys],
          writable_attributes: kwargs[:writable_attributes],
          field_keys: kwargs[:fields].keys
        }
      end
    end

    Object.send(:remove_const, :RecordingStudioApi) if previous_api_defined
    Object.const_set(:RecordingStudioApi, fake_api)
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

      assert_equal "RecordingStudioVideo::Video", registered[:name]
      assert_equal real_video::WRITABLE, registered[:output_keys]
      assert_equal real_video::WRITABLE, registered[:writable_attributes]
      assert_equal real_video::DERIVED, registered[:field_keys]
      refute Object.const_defined?(:Video, false)
    ensure
      if Object.const_defined?(:RecordingStudioApi, false)
        Object.send(:remove_const, :RecordingStudioApi)
      end
      Object.const_set(:RecordingStudioApi, previous_api) if previous_api_defined
      RecordingStudioVideo.send(:remove_const, :Video) if RecordingStudioVideo.const_defined?(:Video, false)
      RecordingStudioVideo.const_set(:Video, real_video)
    end
  end
end
