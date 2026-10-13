# Changelog

## [Unreleased]

## [0.2.0] - 2026-10-13

### Added

- English Rails I18n keys for non-view copy under `recording_studio.video` (field labels, URL hint, and the gem's own "Enter a supported video URL." validation message) resolve through `Copy` from `config/locales/en.yml` only. Call sites do not pass English `default:`; a missing key behaves like main (translation missing / raise-on-missing).
- Host English override coverage: test-only fixture `test/dummy/test/locales/video_host_override.en.yml` loaded via `I18n.backend.load_translations` (no `I18n.load_path` mutation) plus a real-page assert.
- Always-loaded boot-order guard `test/dummy/config/locales/recording_studio_video_host.en.yml` for the rarely shown `errors.enter_supported_video_url` key, with a render assert on the video form error state.
- Locale regression: every `lib/**/*.rb` file must not mention `i18n.load_path` / `I18n.load_path`.
- Render-level asserts for Title / Video URL / Description labels, the URL hint, External Embed provider errors (pass-through), and the gem's own not-video URL error.

### Changed

- `recording_studio_video_fields` resolves field labels, the URL hint, and known URL error messages through `Copy` at render. Lib/playback and `errors[:url]` keep main's English literals; English output stays byte-identical.
- Validation error arrays stay main's English. Displayed form errors map the gem's known English message through `Copy.user_message` at render. External Embed provider messages pass through unchanged.

### Upgrade notes

- Bump to `0.2.0`. No migration.
- English hosts need no change; English comes from the gem's `config/locales/en.yml`.
- Hosts override by defining the same nested keys in their own `config/locales`. Missing keys are not masked with English `default:`.
- Recordable labels (`Video` / `Videos`), generator CLI text, developer `ArgumentError`s, ActiveModel presence (`can't be blank`), and External Embed provider messages stay untranslated in this gem.

## 0.1.0 - 2026-10-06

First release.

### Added

- `RecordingStudioVideo::Video` stores `title`, `url`, and `description` on `recording_studio_videos`.
- `RecordingStudio::Capabilities::Videos.to` mounts videos on a parent such as Workspace.
- `recording_studio_video_fields` and `recording_studio_video_player` render the form and the External Embed player.
- Playback and URL checks go through Recording Studio External Embed. Another video provider from External Embed needs no schema change.

### Upgrade notes

A host that has never installed this gem should do the following.

1. Add `recording_studio_video`, `recording_studio`, `recording_studio_external_embed`, and `flat_pack`.
2. Run `bin/rails generate recording_studio_video:install`.
3. Run `bin/rails generate recording_studio_video:migrations`, then `bin/rails db:migrate`.
4. Add `"RecordingStudioVideo::Video"` to `config.recordable_types`.
5. Include `RecordingStudio::Capabilities::Videos.to` on the parent model.

The install generator does not mount a route. The host owns the form, the routes, and the buttons.

[Unreleased]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.0...v0.2.0
