require "rails_helper"

RSpec.describe "Player screen waiting invite", type: :system do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  let(:game) { Game.create! }
  let(:join_path) { "/games/#{game.code}/players/join" }

  def expect_join_url(url)
    expect(url).to start_with("http")
    expect(URI(url).path).to eq(join_path)
  end

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def page_scroll
    page.evaluate_script("[document.documentElement.scrollHeight, window.innerHeight, document.documentElement.scrollWidth, window.innerWidth]")
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

  describe "with a pointer and no Web Share" do
    before do
      join_as("Bartholomew Ashworth")
      add_players(1)
      expect(page).to have_css("[data-roster] li", count: 2)
    end

    it "copies the join link and confirms, then says when it could not" do
      page.execute_script("window.__copied = null; navigator.clipboard.writeText = (t) => { window.__copied = t; return Promise.resolve() }")
      click_button "Copy link"
      expect(page).to have_button("Copied ✓")
      expect_join_url(page.evaluate_script("window.__copied"))
      expect(page).to have_button("Copy link", wait: 3)

      page.execute_script("navigator.clipboard.writeText = () => Promise.reject(new Error('denied'))")
      click_button "Copy link"
      expect(page).to have_button("Couldn't copy")
      expect(page).to have_button("Copy link", wait: 3)
    end

    it "opens the QR sheet, closes it with Done, and a room update closes it" do
      click_button "Show QR"
      expect(sheet_open?).to be(true)
      within("dialog[data-invite-target=sheet]") do
        expect(page).to have_css("svg")
        expect(page).to have_content(game.code)
        click_button "Done"
      end
      expect(sheet_open?).to be(false)

      click_button "Show QR"
      expect(sheet_open?).to be(true)
      add_players(1)
      expect(page).to have_css("[data-roster] li", count: 3)
      expect(sheet_open?).to be(false)
      click_button "Show QR"
      expect(sheet_open?).to be(true)
    end
  end

  describe "with a touch screen and Web Share" do
    before do
      visit root_path
      bridge = page.driver.browser
      bridge.execute_cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
      @share_stub = bridge.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
        window.__shared = null;
        navigator.share = (data) => { window.__shared = data; return Promise.resolve(); };
      JS
      join_as("Ada")
      add_players(1)
      expect(page).to have_css("[data-roster] li", count: 2)
    end

    after do
      bridge = page.driver.browser
      bridge.execute_cdp("Emulation.setTouchEmulationEnabled", enabled: false)
      bridge.execute_cdp("Page.removeScriptToEvaluateOnNewDocument", identifier: @share_stub["identifier"])
    end

    it "reads Share link and shares the join URL with the room title" do
      expect(page).to have_button("Share link")
      click_button "Share link"
      expect(page).to have_button("Share link")
      shared = page.evaluate_script("window.__shared")
      expect(shared["title"]).to eq("Room #{game.code}")
      expect_join_url(shared["url"])
    end
  end

  describe "with 8 players" do
    before do
      join_as("Bartholomew Ashworth")
      add_players(7)
    end

    [[375, 667], [667, 375], [1024, 640]].each do |width, height|
      it "keeps no page scroll at #{width}x#{height}, sheet closed and open" do
        resize(width, height)
        visit game_controller_path(game.code)
        expect(page).to have_css("[data-roster] li", count: 8)
        expect(page).to have_button("I'm ready")
        expect_no_page_scroll

        click_button "Show QR"
        expect(sheet_open?).to be(true)
        expect_no_page_scroll
        fits = page.evaluate_script("(() => { const r = document.querySelector('dialog[data-invite-target=sheet]').getBoundingClientRect(); return r.top >= 0 && r.bottom <= window.innerHeight && r.left >= 0 && r.right <= window.innerWidth; })()")
        expect(fits).to be(true)
      end
    end
  end
end
