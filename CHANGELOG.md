# Changelog

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
