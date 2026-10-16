# Migration Notes

## Current Requirements

- Ruby 3.3 or newer
- Rails 8.1 or newer
- Recording Studio 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.6.0`)
- Accessible dummy tag `v0.18.0`, Trashable dummy tag `v0.10.0` (`require: false`; query-only for Accessible), Root Switchable dummy tag `v0.9.0`, Cache dummy tag `v0.5.0`
- Dummy-only Metrics pin `v0.3.1` (root Gemfile stays on `v0.2.0`): required by Recording Studio API `v0.11.2` (development/test, `require: false`; gemspec `recording_studio_metrics >= 0.3.0, < 0.4`). API does not depend on Root Switchable.
- Set `RECORDING_STUDIO_VIDEO_LOAD_API=1` to require the API at dummy boot for the registration runner test. That path prepends `test/dummy/config/api_boot_stubs` onto `$LOAD_PATH` so a minimal fake `RecordingStudioAdmin::ScreensController` satisfies API’s `to_prepare` `require_dependency "recording_studio_admin/screens_controller"` without installing Recording Studio Admin.
- FlatPack dummy tag `v0.1.198`
- Public RubyGems and GitHub access for dependency installation

## Verification

Install both bundles and run the complete gem and dummy app test path:

```bash
bundle install
BUNDLE_GEMFILE=test/dummy/Gemfile bundle install
bundle exec rake test:all
```

Run the dummy app from its directory for browser verification:

```bash
cd test/dummy
bin/dev
```

Use the [FlatPack repository](https://github.com/bowerbird-app/flatpack) and the live FlatPack demo linked from the top-level README for current component documentation.
