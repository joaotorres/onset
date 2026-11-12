require "rails_helper"

RSpec.describe "Player screen game over standings", type: :system do
  include_context "game over standings"

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
