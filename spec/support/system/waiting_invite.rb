# Shared by the spec files in spec/system/waiting_invite/.
RSpec.shared_context "waiting invite" do
  include_context "resizable window"

  let(:game) { Game.create! }
  let(:join_path) { "/games/#{game.code}/players/join" }

  def expect_join_url(url)
    expect(url).to start_with("http")
    expect(URI(url).path).to eq(join_path)
  end

  def join_as(name)
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: name
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game.code))
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
  end

  def add_players(count)
    names = ["Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan", "Jonas Oppenheimer",
      "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"]
    free = PlayersController::PRESET_COLORS - game.players.pluck(:color)
    free.zip(names - game.players.pluck(:name)).first(count).each { |color, name| game.players.create!(name: name, color: color) }
  end

  def expect_no_page_scroll
    scroll_height, inner_height, scroll_width, inner_width = page_scroll
    expect(scroll_height).to eq(inner_height)
    expect(scroll_width).to eq(inner_width)
  end

  def sheet_open?
    page.evaluate_script("document.querySelector('dialog[data-invite-target=sheet]')?.open === true")
  end
end

RSpec.shared_context "waiting invite with a pointer and no Web Share" do
  before do
    join_as("Bartholomew Ashworth")
    add_players(1)
    expect(page).to have_css("[data-roster] li", count: 2)
  end
end
