# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "flat_pack", "~> 0.2", github: "bowerbird-app/flatpack", tag: "v0.2.0"
gem "recording_studio", "~> 7.8", github: "bowerbird-app/RecordingStudio", tag: "v7.8.0"
gem "recording_studio_accessible", github: "bowerbird-app/RecordingStudio_accessible", tag: "v0.56.0"
gem "recording_studio_cache", github: "bowerbird-app/RecordingStudio_cache", tag: "v0.8.0"
gem "recording_studio_external_embed", github: "bowerbird-app/RecordingStudio_external_embed", tag: "v0.7.0"
gem "recording_studio_metrics", github: "bowerbird-app/RecordingStudio_metrics", tag: "v0.10.0"
gem "recording_studio_root_switchable", github: "bowerbird-app/RecordingStudio_root_switchable", tag: "v0.16.1"
gem "recording_studio_trashable", github: "bowerbird-app/RecordingStudio_trashable", tag: "v1.2.3", require: false

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
