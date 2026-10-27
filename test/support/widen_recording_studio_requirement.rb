# frozen_string_literal: true

# Accessible 0.18.0, API 0.11.2, Cache 0.5.0, External Embed 0.1.3,
# Metrics 0.2.0 and 0.3.1, Root Switchable 0.9.0, and Trashable 0.11.0
# still require recording_studio below 5. Widen that requirement when
# Bundler loads gemspecs so this app can resolve 6.1.0.
module WidenRecordingStudioRequirement
  def add_dependency(name, *requirements)
    if name.to_s == "recording_studio" && !allows_recording_studio_six?(requirements)
      requirements = [">= 6.1.0"]
    end

    super
  end

  private

  def allows_recording_studio_six?(requirements)
    Gem::Requirement.new(requirements).satisfied_by?(Gem::Version.new("6.1.0"))
  rescue ArgumentError
    false
  end
end

unless Gem::Specification.ancestors.include?(WidenRecordingStudioRequirement)
  Gem::Specification.prepend(WidenRecordingStudioRequirement)
end
