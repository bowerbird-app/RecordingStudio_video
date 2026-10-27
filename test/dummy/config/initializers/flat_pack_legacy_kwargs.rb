# frozen_string_literal: true

# Root Switchable v0.9.0 still builds its switch page with FlatPack kwargs
# removed in Flatpack 0.1.304. v0.10.0 drops those kwargs, but its dropdown
# calls button_attributes, which Flatpack 0.1.319 no longer defines.
module FlatPackPageNavLegacyKeywords
  def initialize(*args, **kwargs, &block)
    href = kwargs.delete(:anchor_url)
    tooltip = kwargs.delete(:anchor_label)
    super(*args, **kwargs, &block)
    with_close(href: href, tooltip: tooltip) if href.present?
  end
end

module FlatPackCardLegacyStyle
  def initialize(*args, style: nil, **kwargs, &block)
    kwargs[:background] ||= :default if style.to_s == "default"
    super(*args, **kwargs, &block)
  end
end

Rails.application.config.to_prepare do
  page_nav = FlatPack::PageNav::Component
  card = FlatPack::Card::Component
  page_nav.prepend(FlatPackPageNavLegacyKeywords) unless page_nav.ancestors.include?(FlatPackPageNavLegacyKeywords)
  card.prepend(FlatPackCardLegacyStyle) unless card.ancestors.include?(FlatPackCardLegacyStyle)
end
