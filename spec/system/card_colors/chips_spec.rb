require "rails_helper"

# SPEC §8 Settings menu, Card colors: each chip shows its own option's colors
# whatever is picked, on the card face.
RSpec.describe "Card colors chips", type: :system do
  include_context "card colors"

  def chip_colors
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('#settings_menu fieldset:nth-of-type(2) label')].map(label => {
        const face = label.querySelector("span.rounded")
        return {
          face: getComputedStyle(face).backgroundColor,
          dots: [...face.querySelectorAll("span")].map(s => getComputedStyle(s).backgroundColor),
          marks: [...face.querySelectorAll("polygon")].map(p => getComputedStyle(p).fill)
        }
      })
    JS
  end

  def expect_own_palettes
    classic_chip, colorblind_chip = chip_colors
    expect(classic_chip).to eq("face" => rgb("#FAFAFA"), "dots" => classic, "marks" => [])
    expect(colorblind_chip).to eq("face" => rgb("#FAFAFA"), "dots" => [], "marks" => colorblind)
  end

  it "shows each option's own palette under Classic and under Color-blind" do
    visit root_path
    open_settings
    expect_own_palettes

    choose "Color-blind", allow_label_click: true
    expect(card_colors_cookie[:value]).to eq("colorblind")
    expect_own_palettes
  end
end
