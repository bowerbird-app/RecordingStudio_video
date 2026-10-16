# frozen_string_literal: true

require "test_helper"

# Hosts that load RecordingStudioApi used to NameError at boot when this gem
# called register_integrations! from the after_initialize initializer before
# the main autoloader could resolve RecordingStudioVideo::Video. They worked
# around it with an early require and/or Object.const_set(:Video, ...).
#
# This subprocess boots the dummy with RECORDING_STUDIO_VIDEO_LOAD_API=1 so
# recording_studio_api is required in application.rb and registration happens
# on the real to_prepare path (not a hand-called register_integrations!).
# Moving registration back onto after_initialize makes this runner exit non-zero.
class VideoApiRegistrationBootTest < ActiveSupport::TestCase
  test "rails runner boot registers Video via to_prepare with RecordingStudioApi loaded" do
    script = <<~'RUBY'
      begin
        raise "top-level Video must not exist" if Object.const_defined?(:Video, false)
        raise "RecordingStudioApi missing" unless defined?(::RecordingStudioApi)

        registration = RecordingStudioApi.recordable_registration_for("RecordingStudioVideo::Video")
        raise "Video not registered" unless registration
        unless registration.writable_attributes == %w[description title url]
          raise "bad writable: #{registration.writable_attributes.inspect}"
        end
        unless registration.output_keys.sort == %w[description title url]
          raise "bad output: #{registration.output_keys.inspect}"
        end
        unless registration.fields.keys.sort == %w[canonical_url content_type provider]
          raise "bad fields: #{registration.fields.keys.inspect}"
        end

        RecordingStudioApi.configuration.validate!
        puts "VIDEO_API_BOOT_OK"
      ensure
        RecordingStudioApi.prepare_recordable_registries_for_reload!
      end
    RUBY

    output = IO.popen(
      { "RECORDING_STUDIO_VIDEO_LOAD_API" => "1" },
      %w[bundle exec bin/rails runner] + [script],
      chdir: Rails.root.to_s,
      err: %i[child out]
    ) { |io| io.read }

    assert_equal true, $?.success?, output
    assert_includes output, "VIDEO_API_BOOT_OK"
    refute Object.const_defined?(:Video, false)
    refute defined?(::RecordingStudioApi)
  end
end
