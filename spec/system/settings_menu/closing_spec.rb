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

  it "closes on Escape after a click on blank space in the menu drops focus to the page" do
    visit root_path
    open_settings
    find('[role="dialog"][aria-label="Settings"] p', text: "Settings").click
    expect(page.evaluate_script("document.activeElement === document.body")).to be(true)
    page.driver.browser.action.send_keys(:escape).perform
    expect(page).to have_no_css('[role="dialog"]', visible: true)
    expect(settings_button["aria-expanded"]).to eq("false")
    expect(focused_label).to eq("Settings")
  end

  it "does nothing on Escape with the menu closed" do
    visit root_path
    find_field("room_code").send_keys(:escape)
    expect(page).to have_no_css('[role="dialog"]', visible: true)
    expect(settings_button["aria-expanded"]).to eq("false")
    expect(page.evaluate_script("document.activeElement.id")).to eq("room_code")
  end

  it "binds Escape on the document only, never on an element" do
    visit root_path
    actions = all("[data-action]", visible: :all).map { |el| el["data-action"] }
    expect(actions.join(" ")).to include("keydown.esc@document->settings#escape")
    expect(actions.flat_map(&:split).grep(/\Akeydown\.esc(?!@document)/)).to be_empty
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
