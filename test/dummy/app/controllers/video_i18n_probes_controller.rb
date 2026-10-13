# frozen_string_literal: true

# Test-only probe: renders the rarely shown boot_mark copy so the
# always-loaded host override under config/locales can be asserted on a
# real page without changing the normal /videos UI.
class VideoI18nProbesController < ApplicationController
  def show
    render layout: false
  end
end
