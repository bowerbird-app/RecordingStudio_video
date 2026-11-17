# Upgrading Recording Studio Video

This gem requires:

- Ruby `>= 3.3.0`
- Rails `~> 8.1.0`
- `recording_studio` `>= 7.0`, `< 8.0`
- `recording_studio_external_embed` `>= 0.6.0`
- `flat_pack` `>= 0.1.341`

Those floors match `recording_studio_video.gemspec`. Development and dummy Gemfiles may pin newer tags; hosts only need the gemspec ranges.

Current development pins are Recording Studio `v7.4.0`, Flatpack `v0.1.377`, Accessible `v0.46.0`, Trashable `v1.0.1`, Cache `v0.7.0`, Root Switchable `v0.16.0`, Metrics `v0.9.1`, and External Embed `v0.6.0`. Dummy development/test also pins API `v1.3.0`, Logs `v0.8.0`, Moveable `v6.0.0`, and Icons `v0.4.1` for the Video API boot test. Hosts do not need those pins unless they load the same gems. API 1.3.0 omits list `meta.total_count` unless the request passes `include_total=true`. This gem does not read that field. Recording Studio 7.4's `index_rs_recordings_on_root_type_created_at_id` migration is optional. The dummy app does not copy it.

## First install

1. Add `recording_studio_video` next to Recording Studio, External Embed, and Flatpack.
2. Run `bin/rails generate recording_studio_video:install`.
3. Run `bin/rails generate recording_studio_video:migrations`, then `bin/rails db:migrate`.
4. Add `"RecordingStudioVideo::Video"` to `config.recordable_types`.
5. Include `RecordingStudio::Capabilities::Videos.to` on the parent model.

The install generator does not mount a route. The host owns the form, the routes, and the buttons.

## This release (0.6.0)

Bump the gem to `0.6.0`. Hosts need Recording Studio 7.0 or newer, below 8.0, and External Embed 0.6.0 or newer. `RecordingStudio.root_recording_for` only finds a root and returns `nil` when there is none. Create a root with `RecordingStudio.create_root_recording!(recordable, actor:)`. Run the Recording Studio migration that adds `recording_studio_events.root_recording_id`. This gem adds no table of its own.

Dummy `authorize_write` still checks Accessible on an existing root. A present actor may create a root. Do not set `allow_unauthorized_writes`. Private Workspace still has no access grant. Playback still goes through External Embed, so a private video has no public or guessable URL of its own.

## 0.5.1

Bump the gem to `0.5.1`. Hosts that still use External Embed 0.1.x keep working; 0.2.x is now allowed. Dummy videos go through Accessible (`authorized?` / `root_recordings_for`) instead of unscoped `Recording.find`. Development pins Recording Studio `v6.5.0`, Accessible `v0.24.2`, Trashable `v0.12.3`, Metrics `v0.7.3`, and External Embed `v0.2.2`. Dummy development/test also pins `recording_studio_api` `v0.17.1` and Logs `v0.7.4` for the Video API boot test. No migration.

## 0.5.0

Hosts need Recording Studio 6.3.0 or newer and Flatpack 0.1.341 or newer. Bump the gem to `0.5.0`. Rebuild host Tailwind and reload kit CSS. No migration. `RecordingStudioVideo.configuration.layout` stays `nil` unless a host sets it.
