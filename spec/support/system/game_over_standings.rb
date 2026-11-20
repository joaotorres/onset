# Shared by the spec files in spec/system/game_over_standings/.
RSpec.shared_context "game over standings" do
  include_context "resizable window"

  let(:game) { Game.create! }

  before do
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: "Bartholomew Ashworth"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game.code))

    taken = game.players.pluck(:color)
    names = ["Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan", "Jonas Oppenheimer",
      "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"]
    (Player::PRESET_COLORS - taken).zip(names).each do |color, name|
      game.players.create!(name: name, color: color)
    end
    game.players.order(:id).zip([6, 7, 4, 3, 2, 3, 1, 0]).each { |p, s| p.update!(score: s) }
    game.update!(status: :ended, board: [], deck: [], discard: [])
  end
end

# One file per size, so each stays under the spec-file time limit.
RSpec.shared_examples "game over standings fit" do |width, height|
  it "keeps no page scroll with 8 players at #{width}x#{height}" do
    resize(width, height)
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-standings] li", count: 8)
    scroll_height, inner_height, scroll_width, inner_width = page_scroll
    expect(scroll_height).to eq(inner_height)
    expect(scroll_width).to eq(inner_width)
    expect(page).to have_button("Play again")
  end
end
