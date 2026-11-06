# frozen_string_literal: true

# Dummy API 0.11.2 still requires recording_studio below 5.
# Widen that requirement when Bundler loads gemspecs so this app can resolve 6.5.0.
module WidenRecordingStudioRequirement
  def add_dependency(name, *requirements)
    requirements = [">= 6.5.0"] if name.to_s == "recording_studio" && !allows_recording_studio_six_five?(requirements)

    super
  end

  private

  def allows_recording_studio_six_five?(requirements)
    Gem::Requirement.new(requirements).satisfied_by?(Gem::Version.new("6.5.0"))
  rescue ArgumentError
    false
  end
end

unless Gem::Specification.ancestors.include?(WidenRecordingStudioRequirement)
  Gem::Specification.prepend(WidenRecordingStudioRequirement)
end
