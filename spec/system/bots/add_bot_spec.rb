require "rails_helper"

# SPEC.md, AI opponent > Adding a bot; §8 Big screen (Waiting).
RSpec.describe "Adding a bot from the big screen", type: :system do
  include_context "settings menu"

  def on(session, &) = Capybara.using_session(session, &)

  def add_button(level) = find("#room_tile button[aria-label='Add #{level} bot']")

  it "adds a bot on a tap, shows its pill and mark without a reload, and goes once play starts" do
    visit root_path
    click_button "Start a game"
    click_link "Use this screen as the big screen instead"
    code = find("[data-room-code]").text
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
    record_tracks

    within("#room_tile [role=group][aria-label='Add a bot']") do
      expect(page).to have_css("button", count: 3)
      expect(page).to have_content(/add a bot/i)
    end
    add_button("Easy").click

    pill = find("#board li", text: "Easy bot")
    expect(pill).to have_css("svg[role=img][aria-label=bot]")
    expect(pill).to have_content("✓")
    expect(tracks).to eq([["bot_added", {"level" => "easy"}]])
    expect(page).to have_content("Need at least 2 players")

    add_button("Hard").click
    expect(page).to have_css("#board li", text: "Hard bot")
    expect(page).to have_content("Need a person to play")
    expect(tracks.last).to eq(["bot_added", {"level" => "hard"}])
    # The tile is still there, and still works, after the broadcast replaced it.
    expect(add_button("Medium")).not_to be_disabled

    on("phone") do
      visit join_game_players_path(code)
      fill_in "player[name]", with: "Alice"
      click_button "Join"
      expect(page).to have_content("You're in")
      row = find("[data-roster] li", text: "Easy bot")
      expect(row).to have_css("svg[role=img][aria-label=bot]")
      expect(row).to have_css("[aria-label=ready]")
      expect(page).not_to have_css("[aria-label='Add a bot']")
      expect(page).not_to have_button("Easy")
      click_button "I'm ready"
      expect(page).to have_button("SET!")
    end

    expect(page).not_to have_css("[aria-label='Add a bot']")
    within("#room_tile") { expect(page).to have_content(code) }
  end

  it "shows the tile to a viewer who is not the host, whose tap adds nothing" do
    game = Game.create!
    visit game_path(game.code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
    add_button("Medium").click
    game.players.create!(name: "Alice", color: Player::PRESET_COLORS.first)
    expect(page).to have_css("#board li", text: "Alice")
    expect(page).not_to have_css("#board li", text: "Medium bot")
    expect(game.players.count).to eq(1)
  end
end
