require "rails_helper"

# SPEC §8 Settings menu, Closing it: leaving the page closes the menu, so
# Back shows it closed (turbo:before-cache).
RSpec.describe "Settings menu and the page cache", type: :system do
  include_context "settings menu"

  it "shows the menu closed after Back from a link followed with it open" do
    visit root_path
    page.execute_script("window.notReloaded = true")
    open_settings

    # The shield covers the page while the menu is open, so a script click.
    page.execute_script("arguments[0].click()", find_link("How to play"))
    expect(page).to have_current_path(how_to_play_path)
    expect(page.evaluate_script("window.notReloaded")).to be(true)

    page.go_back
    expect(page).to have_current_path(root_path)
    expect(page.evaluate_script("window.notReloaded")).to be(true)
    expect(page).to have_css('button[aria-label="Settings"]')
    state = page.evaluate_script(<<~JS)
      [document.querySelector("#settings_menu").hidden,
       document.querySelector('[data-settings-target="shield"]').hidden,
       document.querySelector('button[aria-label="Settings"]').getAttribute("aria-expanded")]
    JS
    expect(state).to eq([true, true, "false"])
  end
end
