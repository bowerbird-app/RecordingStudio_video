# Migration Notes

## Current Requirements

- Ruby 3.3 or newer
- Rails 8.1 or newer
- Recording Studio 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.6.0`)
- Accessible dummy tag `v0.18.0`, Trashable dummy tag `v0.10.0` (`require: false`; query-only for Accessible), Cache dummy tag `v0.5.0`
- Dummy-only (not the root Gemfile): Recording Studio API `v0.11.2` (development/test, `require: false`). That gemspec requires Metrics `~> 0.3` / `>= 0.3.0, < 0.4`, so the dummy pins Metrics `v0.3.1` and Root Switchable `v0.9.4` (which allows Metrics 0.3). The root Gemfile stays on Metrics `v0.2.0` / Root Switchable `v0.9.0` for the gem suite. Set `RECORDING_STUDIO_VIDEO_LOAD_API=1` to require the API at dummy boot for the registration runner test.
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
