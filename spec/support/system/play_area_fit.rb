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
