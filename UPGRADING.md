# Upgrading Recording Studio Video

This gem requires:

- Ruby `>= 3.3.0`
- Rails `~> 8.1.0`
- `recording_studio` `>= 6.3.0`
- `recording_studio_external_embed` `>= 0.1.1`
- `flat_pack` `>= 0.1.341`

Those floors match `recording_studio_video.gemspec`. Development and dummy Gemfiles may pin newer tags; hosts only need the gemspec ranges.

Current development pins are Recording Studio `v6.13.0`, Flatpack `v0.1.374`, Accessible `v0.40.0`, Trashable `v0.15.0`, Cache `v0.6.3`, Root Switchable `v0.15.0`, Metrics `v0.8.0`, and External Embed `v0.2.2`. Dummy development/test also pins API `v0.23.2`, Logs `v0.7.5`, Moveable `v4.1.1`, and Icons `v0.2.1` for the Video API boot test. Hosts do not need those pins unless they load the same gems. Accessible 0.40 requires Recording Studio 6.13.0 or newer. Hosts on Recording Studio 6.9 or newer copy core migration `20261114090000_add_root_recording_id_to_recording_studio_events` before writing events. That column is a Recording Studio migration, not a migration from this gem.

## First install

1. Add `recording_studio_video` next to Recording Studio, External Embed, and Flatpack.
2. Run `bin/rails generate recording_studio_video:install`.
3. Run `bin/rails generate recording_studio_video:migrations`, then `bin/rails db:migrate`.
4. Add `"RecordingStudioVideo::Video"` to `config.recordable_types`.
5. Include `RecordingStudio::Capabilities::Videos.to` on the parent model.

The install generator does not mount a route. The host owns the form, the routes, and the buttons.

## This release (0.5.2)

Bump the gem to `0.5.2`. Gemspec floors are unchanged. Development pins move to Recording Studio `v6.13.0`, Flatpack `v0.1.374`, and Accessible `v0.40.0`. Dummy development/test pins API `v0.23.2` and Logs `v0.7.5`. A host that loads Accessible 0.40 needs Recording Studio 6.13.0 or newer. No migration.

## 0.5.1

Bump the gem to `0.5.1`. Hosts that still use External Embed 0.1.x keep working; 0.2.x is now allowed. Dummy videos go through Accessible (`authorized?` / `root_recordings_for`) instead of unscoped `Recording.find`. Development pins Recording Studio `v6.5.0`, Accessible `v0.24.2`, Trashable `v0.12.3`, Metrics `v0.7.3`, and External Embed `v0.2.2`. Dummy development/test also pins `recording_studio_api` `v0.17.1` and Logs `v0.7.4` for the Video API boot test. No migration.

## 0.5.0

Hosts need Recording Studio 6.3.0 or newer and Flatpack 0.1.341 or newer. Bump the gem to `0.5.0`. Rebuild host Tailwind and reload kit CSS. No migration. `RecordingStudioVideo.configuration.layout` stays `nil` unless a host sets it.
