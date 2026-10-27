# Recording Studio kit pin update

Copied addons now start on the Support host-kit floor.

- Gemspec: `add_dependency "recording_studio", ">= 6.1.0"` and `add_dependency "flat_pack", ">= 0.1.315"`
- Dummy and development pins: Recording Studio `v6.1.0`, Flatpack `1fcbafe94f8eb118f0a22182f63f5110fcc97a56` (0.1.319)
- Authenticated dummy layout: `recording_studio_layout`, with Devise on `"application"`
- Hooks and BaseService come from core; do not copy them into a new addon
- Recordable declarations remain required
- Optional example mixin: `include RecordingStudio::Capabilities::Example.to(**opts)` wraps `RecordingStudio::Capabilities.include_for`. Installing the gem does not enable it globally.
