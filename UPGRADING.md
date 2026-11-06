# Upgrading Recording Studio Video

This gem requires:

- Ruby `>= 3.3.0`
- Rails `~> 8.1.0`
- `recording_studio` `>= 6.3.0`
- `recording_studio_external_embed` `>= 0.1.1`
- `flat_pack` `>= 0.1.341`

Those floors match `recording_studio_video.gemspec`. Development and dummy Gemfiles may pin newer tags; hosts only need the gemspec ranges.

## First install

1. Add `recording_studio_video` next to Recording Studio, External Embed, and Flatpack.
2. Run `bin/rails generate recording_studio_video:install`.
3. Run `bin/rails generate recording_studio_video:migrations`, then `bin/rails db:migrate`.
4. Add `"RecordingStudioVideo::Video"` to `config.recordable_types`.
5. Include `RecordingStudio::Capabilities::Videos.to` on the parent model.

The install generator does not mount a route. The host owns the form, the routes, and the buttons.

## This release (0.5.1)

Bump the gem to `0.5.1`. Hosts that still use External Embed 0.1.x keep working; 0.2.x is now allowed. Dummy videos go through Accessible (`authorized?` / `root_recordings_for`) instead of unscoped `Recording.find`. Development pins Recording Studio `v6.5.0`, Accessible `v0.24.2`, Trashable `v0.12.3`, Metrics `v0.7.3`, and External Embed `v0.2.2`. Dummy does not bundle `recording_studio_api` (`v0.11.2` still requires Recording Studio `~> 4.2`). Dummy Metrics stays `v0.3.1`. No migration.

## 0.5.0

Hosts need Recording Studio 6.3.0 or newer and Flatpack 0.1.341 or newer. Bump the gem to `0.5.0`. Rebuild host Tailwind and reload kit CSS. No migration. `RecordingStudioVideo.configuration.layout` stays `nil` unless a host sets it.
