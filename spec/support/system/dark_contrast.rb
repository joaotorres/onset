# Shared by spec/system/dark_contrast/: the dark muted text, placeholder and
# field border values (DESIGN v7 Shared: Themes (v6), Shared: Rules added in v7).
RSpec.shared_context "dark contrast" do
  # The `muted` theme token, #7C8390.
  let(:muted) { "rgb(124, 131, 144)" }

  def dark!
    emulate_color_scheme("dark")
  end

  def pseudo_style(selector, pseudo, property)
    page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json}), #{pseudo.to_json}).getPropertyValue(#{property.to_json})")
  end

  def token(name)
    page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-#{name}').trim().toLowerCase()")
  end
end
