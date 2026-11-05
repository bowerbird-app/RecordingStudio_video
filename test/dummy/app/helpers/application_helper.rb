module ApplicationHelper
  def dummy_page_nav(title:, subtitle: nil, back_url: nil, back_label: "Home")
    content_for(:title, title)
    content_for(:subtitle, subtitle) if subtitle.present?

    if back_url.present?
      flat_pack_page_nav(round: true, style: :default) do |nav|
        nav.with_back(href: back_url, tooltip: back_label)
      end
    end

    register_page_nav(
      "Sign out",
      main_app.destroy_user_session_path,
      role: :secondary,
      data: { turbo_method: :delete }
    )

    # The root switch renders a partial, so it stays in the custom right slot.
    recording_studio_page_nav_right do
      concat recording_studio_root_switch_dropdown(style: :ghost, size: :md)
    end
  end
end
