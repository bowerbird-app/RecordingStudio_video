# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "flat_pack", github: "bowerbird-app/flatpack", tag: "v0.1.377"
gem "recording_studio", github: "bowerbird-app/RecordingStudio", tag: "v7.3.0"
gem "recording_studio_accessible", github: "bowerbird-app/RecordingStudio_accessible", tag: "v0.45.1"
gem "recording_studio_cache", github: "bowerbird-app/RecordingStudio_cache", tag: "v0.7.0"
gem "recording_studio_external_embed", github: "bowerbird-app/RecordingStudio_external_embed", tag: "v0.6.0"
gem "recording_studio_metrics", github: "bowerbird-app/RecordingStudio_metrics", tag: "v0.9.0"
gem "recording_studio_root_switchable", github: "bowerbird-app/RecordingStudio_root_switchable", tag: "v0.16.0"
gem "recording_studio_trashable", github: "bowerbird-app/RecordingStudio_trashable", tag: "v1.0.0", require: false

gem "devise"
gem "pg", "~> 1.1"
gem "puma"
gem "sprockets-rails"

group :development, :test do
  gem "debug"
  gem "minitest-mock"
  gem "simplecov", require: false
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end
