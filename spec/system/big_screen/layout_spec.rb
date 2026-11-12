require "rails_helper"

RSpec.describe "Big screen", type: :system do
  include_context "resizable window"

  let(:game) { Game.create! }

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

  it "renders the room code at 10rem at 1920x1080" do
    resize(1920, 1080)
    visit game_path(game.code)
    size = page.evaluate_script("getComputedStyle(document.querySelector('[data-room-code]')).fontSize")
    expect(size).to eq("160px")
  end
end
