# Upgrading Recording Studio Video

This gem requires:

- Ruby `>= 3.3.0`
- Rails `~> 8.1.0`
- `recording_studio` `>= 6.1.0`
- `recording_studio_external_embed` `~> 0.1.1`
- `flat_pack` `>= 0.1.315`

Those floors match `recording_studio_video.gemspec`. Development and dummy Gemfiles may pin newer tags; hosts only need the gemspec ranges.

## First install

1. Add `recording_studio_video` next to Recording Studio, External Embed, and Flatpack.
2. Run `bin/rails generate recording_studio_video:install`.
3. Run `bin/rails generate recording_studio_video:migrations`, then `bin/rails db:migrate`.
4. Add `"RecordingStudioVideo::Video"` to `config.recordable_types`.
5. Include `RecordingStudio::Capabilities::Videos.to` on the parent model.

The install generator does not mount a route. The host owns the form, the routes, and the buttons.

## This release (0.3.1)

Patch hygiene and docs only. No schema, API, or gemspec change. Bump the gem to `0.3.1`.
