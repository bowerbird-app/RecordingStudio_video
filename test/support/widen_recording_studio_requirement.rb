# frozen_string_literal: true

# External Embed 0.1.3 and API 0.11.2 still require recording_studio below 5.
# Widen that requirement when Bundler loads gemspecs so this app can resolve 6.3.0.
module WidenRecordingStudioRequirement
  def add_dependency(name, *requirements)
    requirements = [">= 6.3.0"] if name.to_s == "recording_studio" && !allows_recording_studio_six_three?(requirements)

    super
  end

  private

  def allows_recording_studio_six_three?(requirements)
    Gem::Requirement.new(requirements).satisfied_by?(Gem::Version.new("6.3.0"))
  rescue ArgumentError
    false
  end
end

unless Gem::Specification.ancestors.include?(WidenRecordingStudioRequirement)
  Gem::Specification.prepend(WidenRecordingStudioRequirement)
end
