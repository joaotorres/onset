require "rails_helper"

RSpec.describe "Big screen", type: :system do
  before { driven_by :selenium, using: :headless_chrome }

  let(:game) { Game.create! }

  it "joins from this computer in a new tab and shows the pill without a reload" do
    visit game_path(game.code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)

    join_tab = window_opened_by { click_link "Join from this computer" }
    within_window(join_tab) do
      fill_in "player[name]", with: "Alice"
      all("label.cursor-pointer").first.click
      click_button "Join"
      expect(page).to have_current_path(game_controller_path(game.code))
    end

    expect(page).to have_css("#board li", text: "Alice")
  end
end
