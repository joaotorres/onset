require "rails_helper"

# SPEC §8 Settings menu: Escape and the close button return focus to the
# settings button; a tap outside only closes the menu.
RSpec.describe "Closing the settings menu", type: :system do
  include_context "settings menu"

  let(:game) { Game.create! }

  def settings_button = find('button[aria-label="Settings"]')
  def focused_label = page.evaluate_script("document.activeElement.getAttribute('aria-label')")

  it "shows the button on every page and opens the menu with the Theme radios" do
    [root_path, how_to_play_path, join_game_players_path(game.code)].each do |path|
      visit path
      expect(settings_button["aria-expanded"]).to eq("false")
      expect(page).to have_no_css('[role="dialog"]', visible: true)
      open_settings
      expect(settings_button["aria-expanded"]).to eq("true")
      within('[role="dialog"][aria-label="Settings"]') do
        within(:fieldset, "Theme") do
          expect(all("input[type=radio]", visible: :all).map { |r| r.find(:xpath, "..").text }).to eq(["Match device", "Light", "Dark"])
        end
      end
    end
  end

  it "closes on Escape and on the close button, focus back on the settings button" do
    visit root_path
    open_settings
    find_field("Match device", visible: :all).send_keys(:escape)
    expect(page).to have_no_css('[role="dialog"]', visible: true)
    expect(settings_button["aria-expanded"]).to eq("false")
    expect(focused_label).to eq("Settings")

    open_settings
    find('button[aria-label="Close settings"]').click
    expect(page).to have_no_css('[role="dialog"]', visible: true)
    expect(focused_label).to eq("Settings")
  end

  it "closes on a tap outside without pressing what it lands on" do
    visit root_path
    open_settings
    tap_on find("button", text: "Start a game")
    expect(page).to have_no_css('[role="dialog"]', visible: true)
    expect(settings_button["aria-expanded"]).to eq("false")
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_content("Joining room")
    expect(Game.count).to eq(0)

    click_button "Start a game"
    expect(page).to have_content("Joining room")
    expect(Game.count).to eq(1)
  end
end
