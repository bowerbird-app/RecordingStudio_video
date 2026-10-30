# Recording Studio Video (0.4.0)

This gem stores a title, one external video URL, and a description. Playback and URL checks go through Recording Studio External Embed.

Current requirements (gemspec):

- Ruby `>= 3.3.0`
- Rails `~> 8.1.0`
- `recording_studio` `>= 6.1.0`
- `recording_studio_external_embed` `~> 0.1.1`
- `flat_pack` `>= 0.1.331`

Development and dummy pins (not gemspec floors): Recording Studio `v6.1.0`, Flatpack `v0.1.331`. Authenticated dummy layout is `recording_studio_layout`, with Devise on `"application"`.

Hosts add the gem, run the install and migrations generators, add `"RecordingStudioVideo::Video"` to `config.recordable_types`, and include `RecordingStudio::Capabilities::Videos.to` on the parent. The install generator does not mount a route.
