require "rails_helper"

RSpec.describe "Player screen game over standings", type: :system do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  let(:game) { Game.create! }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def page_scroll
    page.evaluate_script("[document.documentElement.scrollHeight, window.innerHeight, document.documentElement.scrollWidth, window.innerWidth]")
  end

  def end_game_with_eight_players
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: "Bartholomew Ashworth"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game.code))

    taken = game.players.pluck(:color)
    names = ["Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan", "Jonas Oppenheimer",
      "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"]
    (PlayersController::PRESET_COLORS - taken).zip(names).each do |color, name|
      game.players.create!(name: name, color: color)
    end
    game.players.order(:id).zip([6, 7, 4, 3, 2, 3, 1, 0]).each { |p, s| p.update!(score: s) }
    game.update!(status: :ended, board: [], deck: [], discard: [])
  end

  before { end_game_with_eight_players }

  [[375, 667], [667, 375], [1024, 640]].each do |width, height|
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

  it "scrolls the standings inside themselves at 375x560, never the page" do
    resize(375, 560)
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-standings] li", count: 8)
    scroll_height, inner_height = page_scroll
    expect(scroll_height).to eq(inner_height)
    list = page.evaluate_script("(() => { const l = document.querySelector('[data-standings]'); return [l.scrollHeight, l.clientHeight, getComputedStyle(l).overflowY]; })()")
    expect(list[0]).to be > list[1]
    expect(list[2]).to eq("auto")
  end

  it "truncates long names on one line" do
    resize(375, 667)
    visit game_controller_path(game.code)
    name = page.evaluate_script("(() => { const n = document.querySelector('[data-standings] [data-name]'); const s = getComputedStyle(n); return [s.textOverflow, s.whiteSpace]; })()")
    expect(name).to eq(%w[ellipsis nowrap])
  end
end
