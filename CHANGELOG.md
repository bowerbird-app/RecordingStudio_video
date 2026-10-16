# Changelog

## [Unreleased]

## [0.2.2] - 2026-10-16

### Fixed

- `RecordingStudioVideo::Api` and `RecordingStudioVideo::Helper` qualify `::RecordingStudioVideo::Video` (and `::RecordingStudioApi` in Api) so resolution does not depend on a top-level `Video` constant.
- `register_integrations!` runs only from `config.to_prepare`, not from the engine `after_initialize` initializer. Calling it during that initializer NameErrors in hosts that already load `RecordingStudioApi`, because the main autoloader is not ready yet for `::RecordingStudioVideo::Video`.

### Upgrade notes

- Bump to `0.2.2`. No migration.
- featured_in (and similar hosts that load `RecordingStudioApi`): bump this gem to `0.2.2`, confirm the app boots, then delete the whole host `recording_studio_video_api_constant` initializer (including the early model `require`). Do not remove that initializer on `<= 0.2.1`.

## [0.2.1] - 2026-10-13

### Added

- English key `recording_studio.video.errors.url.enter_supported` for this gem's not-video URL message (`Enter a supported video URL.`). `Playback::NotVideo#message` looks it up through `Copy` with no English `default:`.
- Host override coverage for `enter_supported` on a fresh `I18n::Backend::Simple` (real not-video form render) plus `:fr` lookup coverage.
- Packaged `config/locales/en.yml` no longer ships `probes.*`. Dummy boot-order override targets packaged `errors.url.enter_supported` (only shown after an invalid submit).

### Changed

- `errors.add(:url, …)` for the not-video case still passes a String as the error type (same as main). The String is the translated lookup so `:en` stays byte-identical; in non-en locales `errors[:url]` details carry the translated string.
- Presence (`:blank`) and External Embed unresolved messages stay main's symbol / External Embed English literals. No persistence or publish sink stores these validation strings.

### Upgrade notes

- Bump to `0.2.1`. No migration.
- Hosts that override `errors.url.enter_supported` change the not-video form message. Missing keys are not masked with English `default:`.
- External Embed provider messages remain untranslated in this gem.

## [0.2.0] - 2026-10-13

### Added

- English Rails I18n keys for non-view field labels and the URL hint under `recording_studio.video` resolve through `Copy` from `config/locales/en.yml` only. Call sites do not pass English `default:`; a missing key behaves like main (translation missing / raise-on-missing).
- Host English override coverage: test-only fixture `test/dummy/test/locales/video_host_override.en.yml` loaded onto a fresh `I18n::Backend::Simple` via public `load_translations` (no `I18n.load_path` mutation) covering title, URL label, URL hint, and description on a real page.
- Boot-order host override: always-loaded dummy `config/locales/recording_studio_video_boot_override.en.yml` on rarely shown `probes.boot_mark`, asserted via test-only `/video_i18n_probe` (normal `/videos` UI stays gem English).
- Locale regression: every `lib/**/*.rb` file must not mention `i18n.load_path` / `I18n.load_path`.
- Render-level asserts for Title / Video URL / Description labels, the URL hint, and URL errors (main English).

### Changed

- `recording_studio_video_fields` resolves field labels and the URL hint through `Copy` at render. Lib/playback and `errors[:url]` keep main's English literals; English output stays byte-identical.
- URL validation messages (including this gem's "Enter a supported video URL.") stay main's English at the form; they are not wired through I18n in this release.

### Upgrade notes

- Bump to `0.2.0`. No migration.
- English hosts need no change; English for field labels/hint comes from the gem's `config/locales/en.yml`.
- Hosts override field labels/hint by defining the same nested keys in their own `config/locales`. Missing keys are not masked with English `default:`.
- Recordable labels (`Video` / `Videos`), generator CLI text, developer `ArgumentError`s, ActiveModel presence (`can't be blank`), URL validation messages, and External Embed provider messages stay untranslated in this gem.

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

[Unreleased]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.4...v0.2.0
