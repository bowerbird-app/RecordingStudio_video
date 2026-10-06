# Recording Studio Video

Recording Studio Video stores one external video as a Recording Studio recordable. The row keeps a title, a URL, and a description. Playback and URL checks go through Recording Studio External Embed.

## What this gem does not do

This gem does not upload video files. It does not transcode video. It does not parse provider URLs. It does not call the YouTube Data API.

Provider details stay on the embed returned by `RecordingStudio::ExternalEmbed.resolve`. They are not columns.

## Install

Add the gem next to Recording Studio, External Embed, and Flatpack.

```ruby
gem "recording_studio", "~> 4.2"
gem "recording_studio_external_embed", "~> 0.1.1"
gem "flat_pack", ">= 0.1.135"
gem "recording_studio_video", "~> 0.1.0"
```

This repository pins GitHub tags `v4.2.2`, `v0.1.3`, and `v0.1.198` for Recording Studio, External Embed, and Flatpack. This gem does not depend on the YouTube Data API gem. When a host already loads `RecordingStudioApi`, a video registers `title`, `url`, and `description` as writable fields. `provider`, `canonical_url`, and `content_type` are read-only fields derived at response time.

Then install the config and the table.

```bash
bin/rails generate recording_studio_video:install
bin/rails generate recording_studio_video:migrations
bin/rails db:migrate
```

Add the type and keep declaration checks on.

```ruby
RecordingStudio.configure do |config|
  config.recordable_types = ["Workspace", "RecordingStudioVideo::Video"]
  config.require_recordable_declarations = true
end
```

The install generator does not mount a route. The host owns the form, the routes, and the buttons.

## External Embed

Validation and the player both resolve the stored URL with `RecordingStudio::ExternalEmbed.resolve`. A stored URL is valid when that resolution returns an embed whose content type is video. That resolution is the only provider check in this gem.

The shipped External Embed catalog is YouTube only. When External Embed adds another video provider, this gem keeps the same `url` column. No migration is required.

## Fields

`RecordingStudioVideo::Video::WRITABLE` is `title`, `url`, and `description`.

Blank title and description are stored as nil. The URL is stripped and kept as entered. The gem does not copy the embed title, description, canonical URL, or embed URL onto the row.

`provider`, `canonical_url`, and `content_type` are derived readers. They return strings or nil. They are not columns.

The form param key is `video`, from `model_name` `Video`. The Recording Studio type string stays `RecordingStudioVideo::Video`.

## Create a video

`record` defaults the parent to the root. Pass `parent_recording:` when the video should sit under that root.

```ruby
root.record(RecordingStudioVideo::Video, parent_recording: root) do |video|
  video.title = "Me at the zoo"
  video.url = "https://www.youtube.com/watch?v=jNQXAC9IVRw"
  video.description = "The first video uploaded to YouTube."
end
```

A saved video is immutable. Change it with `revise`.

```ruby
root.revise(recording) do |video|
  video.description = "Updated description."
end
```

`root.videos` returns child recordings of type `RecordingStudioVideo::Video`, ordered by `created_at`.

## Mount videos on a parent

Include the capability on the parent model. Workspace is the usual parent. There is no parent-type list to configure.

```ruby
class Workspace < ApplicationRecord
  recording_studio_recordable label: "Workspace", root: true
  include RecordingStudio::Capabilities::Videos.to
end
```

`Videos.to` takes no arguments. A type that does not include it cannot record a video.

## Helpers

The engine includes two helpers into Action Controller, the same way External Embed includes `recording_studio_external_embed`.

`recording_studio_video_fields(video)` renders Title, Video URL, and Description with Flatpack, with space between each field. The URL hint is `Paste a link to a supported video, such as YouTube.` URL errors use `video.errors[:url]`. This helper does not render the player.

`recording_studio_video_player(subject)` accepts a `RecordingStudioVideo::Video` or a `RecordingStudio::Recording` whose recordable is a video. It renders that URL with `recording_studio_external_embed`. It does not build an iframe and it does not print the title. Anything else returns an empty HTML-safe string.

Put the player under the fields when `video.content_type` is `"video"`.

## Validation

`url` is required.

| Case | `errors[:url]` |
| --- | --- |
| Blank | `can't be blank` |
| Unsupported host | `That URL is not from a supported provider.` |
| Malformed id | `That URL is missing a valid id.` |
| URL that cannot be embedded | `That URL can't be embedded.` |
| Resolved embed that is not a video | `Enter a supported video URL.` |

Those provider messages come from External Embed. This gem does not keep a provider regex.
