# Shared by spec/system/big_screen_fit/: elements inside #board's box (SPEC §8 Big screen, Fit).
RSpec.shared_context "play area fit" do
  include_context "big screen theme"

  def rects_of(selector)
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll(#{selector.to_json})].map(e => {
        const r = e.getBoundingClientRect()
        return {top: r.top, bottom: r.bottom, left: r.left, right: r.right}
      })
    JS
  end

  def expect_inside_board(*selectors)
    board = rect("#board")
    expect(board["bottom"]).to be <= rect("#announcement")["top"]
    selectors.each do |selector|
      list = rects_of(selector)
      expect(list).not_to be_empty, "no #{selector}"
      list.each do |r|
        expect(r["top"]).to be >= board["top"] - 0.5, "#{selector} top #{r["top"]} above board #{board["top"]}"
        expect(r["bottom"]).to be <= board["bottom"] + 0.5, "#{selector} bottom #{r["bottom"]} below board #{board["bottom"]}"
      end
    end
  end

  def font_px(selector) = page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json})).fontSize")

  def height_of(selector) = rect(selector)["height"]
end

FIT_SIZES = [[1280, 720], [1366, 768], [1280, 800], [1440, 900], [1280, 1024]].freeze

# Shared by big_screen_fit/waiting*_spec.rb: 8 players, 4 start votes in.
RSpec.shared_context "waiting fit" do
  include_context "play area fit"

  before do
    add_players(8)
    game.update!(start_voters: game.players.first(4).map(&:id))
  end

  def expect_waiting_fits
    expect(page).to have_css("#start_button button")
    expect_inside_board("[data-qr-tile]", "[data-join-here]", "[data-hero-text] > p", "#board li", "#start_button")
    expect_join_link_under_qr
    expect_settings_in_corner
  end

  # SPEC §8 Big screen, Fit: the QR never under 160px, the link on one line under its tile, no wider than it.
  def expect_join_link_under_qr
    expect(rect("[data-qr-tile] svg")["width"]).to be >= 160
    link = rect("[data-join-here]")
    qr = rect("[data-qr-tile]")
    expect(link["top"]).to be >= qr["bottom"]
    expect(link["width"]).to be <= qr["width"], "link #{link["width"]}px wider than its #{qr["width"]}px tile"
    line = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('[data-join-here]')).lineHeight)")
    expect(link["height"]).to be <= line + 0.5, "link #{link["height"]}px tall, more than one #{line}px line"
  end
end

# Shared by big_screen_fit/ended*_spec.rb: 8 players, a long winner name, ended.
RSpec.shared_context "ended fit" do
  include_context "play area fit"

  before do
    players = add_players(8)
    players[0].update!(name: "Alexandria Pemberton", score: 9)
    players[1].update!(name: "Samuel Wainwright", score: 7)
    players[2].update!(name: "Priya Ramanathan", score: 5)
    game.update!(status: :ended)
  end

  def expect_ended_fits
    expect(page).to have_button("Play again")
    expect_inside_board("#board > p", "#board h2", "#board .w-56", "#board form")
    headline = page.evaluate_script("(() => { const h = document.querySelector('#board h2'); return [h.scrollWidth, h.clientWidth, getComputedStyle(h).textOverflow, h.textContent]; })()")
    expect(headline[0]).to be <= headline[1]
    expect(headline[2]).not_to eq("ellipsis")
    expect(headline[3]).to include("Alexandria Pemberton")
    expect_settings_in_corner
  end
end
