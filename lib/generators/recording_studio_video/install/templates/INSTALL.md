RecordingStudioVideo install complete.

Next steps:

1. Review `config/initializers/recording_studio_video.rb`.
2. Install the migrations with `bin/rails generate recording_studio_video:migrations`.
3. Apply the migrations with `bin/rails db:migrate`.
4. Add `"RecordingStudioVideo::Video"` to `config.recordable_types`.
5. Include `RecordingStudio::Capabilities::Videos.to` on the parent model that should hold videos.
6. Keep `config.require_recordable_declarations = true`.
7. Run `bin/rails tailwindcss:build` if you use Tailwind CSS.

This gem does not mount a route. The host owns the form, the routes, and the buttons. Render `recording_studio_video_fields` and `recording_studio_video_player` from the host views.
