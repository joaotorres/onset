require "rails_helper"

RSpec.describe "Big screen", type: :system do
  before { driven_by :selenium, using: :headless_chrome }

  let(:game) { Game.create! }

  it "shows the room tile without a reload once the ready votes start the game" do
    visit game_path(game.code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
    expect(page).to have_css("svg[shape-rendering='crispEdges']", count: 1)
    expect(page).not_to have_css("#room_tile p")

    %w[Alice Bob].each_with_index do |name, i|
      Capybara.using_session("phone#{i}") do
        visit join_game_players_path(game.code)
        fill_in "player[name]", with: name
        all("label.cursor-pointer")[i].click
        click_button "Join"
        expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      end
    end
    # Ready is disabled until a second player joins, so vote once both are in.
    %w[phone0 phone1].each { |phone| Capybara.using_session(phone) { click_button "I'm ready" } }

    within("#room_tile") do
      expect(page).to have_content(/room/i)
      expect(page).to have_content(game.code)
    end
    expect(page).not_to have_css("svg[shape-rendering='crispEdges']")
  end
end
