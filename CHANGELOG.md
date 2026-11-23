# Changelog

## [Unreleased]

## [0.7.1] - 2026-11-23

### Changed

- URL validation adds Active Record symbols (`:unsupported`, `:malformed`, `:invalid`, `:enter_supported`) instead of External Embed sentence strings. Phrase-form English lives under `activerecord.errors.models.recording_studio_video/video.attributes.url`, so `errors.full_messages` reads as `Url is not from a supported provider` while `errors[:url]` stays usable on the form. Unresolved reasons still come from `ExternalEmbed::Unresolved#reason`.
- `RecordingStudioVideo::Video.model_name` is namespaced (`ActiveModel::Name.new(self, RecordingStudioVideo)`). The form param key stays `video`. The i18n key is `recording_studio_video/video`.
- The dummy test database default and CI Postgres database are `recording_studio_video_test`.
- README documents the shipped External Embed catalog as YouTube and Vimeo.

### Upgrade notes

- Bump to `0.7.1`. No migration. Clients that displayed `errors.full_messages` no longer see `Url That URL is not from a supported provider.` Form fields still read `errors[:url]`, now in phrase form (`is not from a supported provider`). Hosts that overrode `recording_studio.video.errors.url.enter_supported` should also override `activerecord.errors.models.recording_studio_video/video.attributes.url.enter_supported`.
- Compare [v0.7.0...v0.7.1](https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.7.0...v0.7.1).

## [0.7.0] - 2026-11-19

### Changed

- Development and dummy Gemfiles pin Recording Studio `v7.8.0` (`~> 7.8`) and Flatpack `v0.2.0` (`~> 0.2`). Accessible is `v0.56.0`, Trashable `v1.2.3`, Cache `v0.8.0`, Metrics `v0.10.0`, External Embed `v0.7.0`, and Root Switchable `v0.16.1`. Dummy also pins API `v1.19.0`, Logs `v0.8.2`, Moveable `v6.0.3`, and Icons `v0.5.0`.
- The dummy importmap drops the manual `flat_pack/heroicons` pin. `test/dummy/install_page.html` drops that pin and the `flat-pack--icon` controller.
- The dummy app does not copy Recording Studio 7.4, 7.5, or 7.7 migrations. Gemspec floors stay `recording_studio >= 7.0`, `< 8.0` and `flat_pack >= 0.1.341`.

### Upgrade notes

- Bump to `0.7.0`. No migration from this gem. Hosts MUST run the Recording Studio 7.4, 7.5 and 7.7 migrations if they have not.
- flat_pack 0.2.0 is supported; hosts moving to 0.2 must remove the manual `flat_pack/heroicons` importmap pin and any `flat-pack--icon` controller registration.
- Compare [v0.6.5...v0.7.0](https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.5...v0.7.0).

## [0.6.5] - 2026-11-18

### Fixed

- `RecordingStudioVideo::Api.register!` passes `auto_capability_actions: false`. Trash, Restore, Purge, and List trash bin are not added to the Video public API when a host turns on trashable. Writable fields stay `title`, `url`, and `description`. Derived fields stay `provider`, `canonical_url`, and `content_type`. The registration still sets no OpenAPI tags.

### Upgrade notes

- Bump to `0.6.5`. No migration. Hosts that load Recording Studio API no longer see Trash, Restore, Purge, or List trash bin on Video.

## [0.6.4] - 2026-11-18

### Changed

- Development and dummy Gemfiles pin Recording Studio `v7.7.1`, Flatpack `v0.1.378`, Accessible `v0.54.1`, Trashable `v1.2.1`, Cache `v0.7.1`, Metrics `v0.9.2`, and External Embed `v0.6.1`. Root Switchable stays `v0.16.0`. Dummy also pins API `v1.16.0`, Logs `v0.8.1`, Moveable `v6.0.2`, and Icons `v0.4.2`.
- Dummy `config/recording_studio_api.yml` is `shared: {}` so API 1.16 can boot. API still omits list `meta.total_count` unless the request passes `include_total=true`. This gem does not read that field.
- The dummy app does not copy Recording Studio 7.4, 7.5, or 7.7 migrations.

### Upgrade notes

- Bump to `0.6.4`. No migration from this gem. Hosts on Recording Studio 7.4, 7.5, or 7.7 MUST run `20261116120000_add_recording_studio_events_timeline_index`, `20261116230000_add_recording_studio_recordings_root_type_creation_index`, `20261117120000_enforce_recording_studio_recording_root_invariant`, and `20261117200000_replace_recording_studio_recordings_root_index`. The dummy app does not copy them. Hosts that load API 1.12 or newer need `config/recording_studio_api.yml`. Clients that read API list `meta.total_count` pass `include_total=true`.

## [0.6.3] - 2026-11-17

### Fixed

- `RecordingStudioVideo::Api.register!` no longer passes OpenAPI tags. MCP 0.36.5 copies those tags onto the docs sidebar even when no tool uses them, so the Video group was empty. Trash tools stay in Video Trash. MCP builds that name from the public type name `Video` plus Trashable's `tag_suffix` `Trash`.

### Upgrade notes

- Bump to `0.6.3`. No migration. Hosts on Recording Studio MCP 0.36.5 no longer see an empty Video group. Trash, restore, purge, and list trash bin stay under Video Trash.

## [0.6.2] - 2026-11-17

### Fixed

- Video MCP docs use the group `Video`. `RecordingStudioVideo::Api.register!` passes `openapi` tags `["Video"]` to `register_recordable_type_api`, the same tag list Presskits sets per type. Trash, restore, purge, and list trash bin titles still come from Trashable until MCP reads a per-type title.

### Upgrade notes

- Bump to `0.6.2`. No migration. Hosts on Recording Studio MCP 0.36.3 see Video tools under `Video` instead of the untagged Tools group. Trash tool titles stay Trashable's shared titles.

## [0.6.1] - 2026-11-17

### Changed

- Development and dummy Gemfiles pin Recording Studio `v7.4.0`, Accessible `v0.46.0`, Trashable `v1.0.1`, and Metrics `v0.9.1`. Dummy also pins Icons `v0.4.1` and API `v1.3.0`. Flatpack stays `v0.1.377`. Cache stays `v0.7.0`. Root Switchable stays `v0.16.0`. External Embed stays `v0.6.0`. Logs stays `v0.8.0`. Moveable stays `v6.0.0`.
- API 1.3.0 omits list `meta.total_count` unless the request passes `include_total=true`. This gem does not read that field.
- The dummy app does not copy Recording Studio 7.4's optional `index_rs_recordings_on_root_type_created_at_id` migration.

### Upgrade notes

- Bump to `0.6.1`. No migration from this gem. Hosts that install Recording Studio 7.4 may add its optional recordings index. Clients that read API list `meta.total_count` pass `include_total=true`.

## [0.6.0] - 2026-11-15

### Changed

- Require `recording_studio` `>= 7.0`, `< 8.0` and `recording_studio_external_embed` `>= 0.6.0`.
- Development and dummy Gemfiles pin Recording Studio `v7.0.0`, External Embed `v0.6.0`, Accessible `v0.43.1`, Trashable `v0.16.1`, and Root Switchable `v0.15.1`. Flatpack stays `v0.1.356`. Cache stays `v0.6.3`. Metrics stays `v0.8.0`. Logs stays `v0.7.4`. Dummy development/test pins API `v0.23.4` so Accessible 0.43 can register `openapi_for`. Moveable stays `v4.1.1` and Icons stay `v0.2.1`. Admin stays unpinned.
- Dummy seeds and tests create roots with `create_root_recording!`. Lookups stay on `root_recording_for`, which no longer creates a root. The root switcher still looks roots up.
- Dummy `authorize_write` still requires Accessible `:edit` on an existing root. A present actor may create a root, because core 7 authorizes that write before the root exists. `allow_unauthorized_writes` stays off.
- Dummy seed child lookup uses `Recording.kept`. Trashable 0.16 removed `recording_studio_trashable_kept_sql`.
- Copy Recording Studio 7's `root_recording_id` events migration into the dummy. Private Workspace still has no access grant. Playback still goes through External Embed. External Embed 0.6 recognizes Vimeo, so a Vimeo URL is a video. An unknown host stays unsupported.
- Bump dummy `msgpack` to 1.8.7 (GHSA-73v3-wf97-vpgj). Bootsnap still allows `~> 1.5`.

### Upgrade notes

- Bump to `0.6.0`. Hosts need Recording Studio 7.0 or newer, below 8.0, and External Embed 0.6.0 or newer. Replace root-creating `root_recording_for` calls with `create_root_recording!(recordable, actor:)`. Run Recording Studio's `root_recording_id` events migration. No migration from this gem.

## [0.5.1] - 2026-11-06

### Changed

- Dummy videos authorize through Recording Studio Accessible. Index lists `root_recordings_for`; create/edit load a recording then `authorized?` (`:view` to list, `:edit` to write). Missing access is a 404. `ApplicationController` uses `RecordingStudioAccessible::ControllerAuth` (Devise still identifies). Dummy `config.authorize_write` allows `AccessCreationContext` only when the recordable is `RecordingStudio::Access`. Other writes still need Accessible `:edit` on the root. Seeds grant the demo admin on Studio Workspace and Client Workspace, not Private Workspace.
- Loosen `recording_studio_external_embed` to `>= 0.1.1` (was `~> 0.1.1`). Development and dummy Gemfiles pin External Embed `v0.2.2`, Recording Studio `v6.5.0`, Accessible `v0.24.2`, Trashable `v0.12.3`, and Metrics `v0.7.3`. Dummy bundles `recording_studio_api` `v0.17.1` (`require: false`) plus Logs `v0.7.4` so the Video API boot test can run next to External Embed `v0.2.2` without a `Gem::Specification` prepend. Admin stays unpinned here.

### Upgrade notes

- Bump to `0.5.1`. Hosts that copy the dummy video screens must grant Accessible roles before those actions succeed. Dummy development/test bundles `recording_studio_api` `v0.17.1` for the registration boot test. No migration.

## [0.5.0] - 2026-11-05

### Changed

- Require `recording_studio` >= 6.3.0 and `flat_pack` >= 0.1.341. Development Gemfile pins Recording Studio `v6.3.0`, Accessible `v0.24.1`, Trashable `v0.12.2`, Metrics `v0.7.2`, Cache `v0.6.2`, Root Switchable `v0.11.5`, and Flatpack `v0.1.341`. Dummy keeps Metrics `v0.3.1` and API `v0.11.2` so that boot test still resolves without adding Logs. `recording_studio_external_embed` stays `~> 0.1.1` (pin `v0.1.3`).
- `RecordingStudioVideo.configuration.layout` still defaults to `nil` and is validated with `RecordingStudio::Layout.accept`. Engine controllers keep `recording_studio_layout`.
- Refresh Rails to 8.1.4.1 and the matching security gems (nokogiri, loofah, rails-html-sanitizer).
- Remove leftover template files `docs/gem_template/`, `UPDATE_SUMMARY.md`, and `MIGRATION_NOTES.md`. Dummy no longer prepends Flatpack PageNav/Card kwargs. Dummy Save/Cancel sit in `FlatPack::ButtonGroup` (`variant: :outlined`).

### Upgrade notes

- Bump to `0.5.0`. Hosts need Recording Studio 6.3.0 or newer and Flatpack 0.1.341 or newer. Rebuild host Tailwind and reload kit CSS. No migration.
- `RecordingStudioVideo.configuration.layout` stays `nil` unless a host sets it. `nil` uses the host Recording Studio layout, then `recording_studio/default_layout`.

## [0.4.0] - 2026-10-30

### Changed

- Require `flat_pack` >= 0.1.331. Development and dummy Gemfiles pin GitHub tag `v0.1.331`.
- Video form fields wrap in `FlatPack::Stack::Component` with the default gap (`:md`).

### Upgrade notes

- Bump to `0.4.0`. Hosts need Flatpack 0.1.331 or newer. Rebuild host Tailwind so `flex-col` and `gap-[var(--stack-gap-md)]` exist if the host did not already use them. Reload kit CSS. No migration.

## [0.3.1] - 2026-10-29

### Changed

- Ignore generated SimpleCov output in `coverage/` and `test/dummy/coverage/` (untracked; files stay on disk).
- Copilot instructions name this gem (`recording_studio_video`) instead of the gem template.
- `UPDATE_SUMMARY.md` describes the current video gem. `UPGRADING.md` lists gemspec requirements and host install steps.
- Dummy starter docs copy names this video gem in everyday words.

### Upgrade notes

- Bump to `0.3.1`. No migration. No gemspec or API change.

## [0.3.0] - 2026-10-27

### Changed

- Require `recording_studio` >= 6.1.0 and `flat_pack` >= 0.1.315.
- Development and dummy Gemfiles pin Recording Studio `v6.1.0` and Flatpack `1fcbafe94f8eb118f0a22182f63f5110fcc97a56` (0.1.319).
- `RecordingStudioVideo::Configuration#layout` defaults to `nil` and is validated with `RecordingStudio::Layout.accept`.
- The engine controller and the dummy controller call `recording_studio_layout`. The shared default layout draws one page title from `content_for :title` and `content_for :subtitle`.
- Dummy back and close use `flat_pack_page_nav`. Sign out uses `register_page_nav`. The root switch stays in `recording_studio_page_nav_right`.

### Upgrade notes

- Hosts need Recording Studio 6.1.0 or newer and Flatpack 0.1.315 or newer.
- Set the page heading with `content_for :title` and `content_for :subtitle`. Do not render a second `FlatPack::PageTitle` for that same heading.
- `RecordingStudioVideo.configuration.layout` overrides the layout for this engine's controllers. `nil` keeps the host Recording Studio layout, then `recording_studio/default_layout`.

## [0.2.6] - 2026-10-19

### Changed

- Dummy pin: `recording_studio_trashable` `v0.11.0` (#13).

### Upgrade notes

- Bump to `0.2.6` if you use the dummy Trashable pin. No migration.

## [0.2.5] - 2026-10-16

### Fixed

- `RecordingStudioVideo::Api` and `RecordingStudioVideo::Helper` qualify `::RecordingStudioVideo::Video` (and `::RecordingStudioApi` in Api) so resolution does not depend on a top-level `Video` constant.
- `register_integrations!` runs only from `config.to_prepare`, not from the engine `after_initialize` initializer. Calling it during that initializer NameErrors in hosts that already load `RecordingStudioApi`, because the main autoloader is not ready yet for `::RecordingStudioVideo::Video`.

### Upgrade notes

- Bump to `0.2.5` (above existing tags `v0.2.2`–`v0.2.4`). No migration.
- featured_in (and similar hosts that load `RecordingStudioApi`): bump this gem to `0.2.5`, confirm the app boots, then delete the whole host `recording_studio_video_api_constant` initializer (including the early model `require`). Do not remove that initializer on older tags (including `v0.2.2`–`v0.2.4`).

## [0.2.4] - 2026-10-14

### Changed

- Dummy pin: `recording_studio_accessible` `v0.18.0` (#12).

### Upgrade notes

- Bump to `0.2.4` if you follow the dummy Accessible pin. No migration.

## [0.2.3] - 2026-10-14

### Changed

- Dummy/development pin: `recording_studio` `v4.6.0` (#11).

### Upgrade notes

- Bump to `0.2.3` if you follow that Recording Studio pin. No migration. Later tags require Recording Studio 6.1.0.

## [0.2.2] - 2026-10-13

### Changed

- Dummy pins: `recording_studio_accessible` `v0.17.0` and `recording_studio_root_switchable` `v0.9.0` (#9).

### Upgrade notes

- Bump to `0.2.2` if you follow those dummy pins. No migration.

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

## [0.1.4] - 2026-10-12

### Changed

- Dummy pin: `recording_studio_accessible` `v0.15.0` (#7).
- Dummy/development pin: `recording_studio` `v4.5.0` (#6).
- Dummy pin: `recording_studio_root_switchable` `v0.8.0` (#5).

### Upgrade notes

- Bump to `0.1.4` if you follow those pins. No migration.

## [0.1.3] - 2026-10-09

### Changed

- Dummy pins for i18n gem releases: `recording_studio_accessible` and `recording_studio_root_switchable` (#4).

### Upgrade notes

- Bump to `0.1.3` if you follow those dummy pins. No migration.

## [0.1.2] - 2026-10-09

### Changed

- Dummy/development pin: `recording_studio` `v4.4.0` (#3).

### Upgrade notes

- Bump to `0.1.2` if you follow that Recording Studio pin. No migration.

## [0.1.1] - 2026-10-08

### Changed

- Dummy/development pin: `recording_studio` `v4.3.0` (#2).

### Upgrade notes

- Bump to `0.1.1` if you follow that Recording Studio pin. No migration.

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

[Unreleased]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.7.1...HEAD
[0.7.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.5...v0.7.0
[0.6.5]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.4...v0.6.5
[0.6.4]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.3...v0.6.4
[0.6.3]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.6...v0.3.0
[0.2.6]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.4...v0.2.0
[0.1.4]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/bowerbird-app/RecordingStudio_video/compare/v0.1.0...v0.1.1
