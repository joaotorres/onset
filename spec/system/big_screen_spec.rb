require "rails_helper"

RSpec.describe "Big screen", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  let(:game) { Game.create! }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def rect(selector)
    page.evaluate_script("(() => { const r = document.querySelector(#{selector.to_json}).getBoundingClientRect(); return {left: r.left, right: r.right, top: r.top, bottom: r.bottom, height: r.height}; })()")
  end

  def hero_rects
    page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll("[data-hero-text] > p")).map(p => {
        const range = document.createRange();
        range.selectNodeContents(p);
        return range.getBoundingClientRect().right;
      })
    JS
  end

  it "fits the hero text left of the rail at 1280x800, code on one line" do
    resize(1280, 800)
    visit game_path(game.code)
    expect(page).to have_css("[data-room-code]", text: game.code)

    rail_left = rect("main > aside")["left"]
    expect(hero_rects).to all(be < rail_left)

    code = rect("[data-room-code]")
    line_height = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('[data-room-code]')).fontSize)")
    expect(code["height"]).to be < line_height * 1.5

    qr = rect("[data-qr-tile]")
    link = rect("[data-join-here]")
    expect(link["top"]).to be >= qr["bottom"]
    expect(link["right"] - link["left"]).to be <= qr["right"] - qr["left"]
    link_line = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('[data-join-here]')).lineHeight)")
    expect(link["height"]).to be < link_line * 1.5
  end

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

  it "renders the room code at 10rem at 1920x1080" do
    resize(1920, 1080)
    visit game_path(game.code)
    size = page.evaluate_script("getComputedStyle(document.querySelector('[data-room-code]')).fontSize")
    expect(size).to eq("160px")
  end

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
