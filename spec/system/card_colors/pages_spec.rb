require "rails_helper"

# SPEC §10 Palette on the landing and How to play: the fanned cards and the
# diagrams follow the palette, and How to play's words name the colors shown.
RSpec.describe "Card colors on the landing and How to play", type: :system do
  include_context "card colors"

  def captions = all("section figcaption", text: /\A(red|green|purple|blue|orange|magenta)\z/).map(&:text)

  # Text in the accessibility tree: what a screen reader would read.
  def readable_text
    page.evaluate_script(<<~JS)
      (() => {
        const walker = document.createTreeWalker(document.querySelector("main"), NodeFilter.SHOW_TEXT)
        const out = []
        while (walker.nextNode()) {
          const el = walker.currentNode.parentElement
          if (el.closest("[aria-hidden=true]") || getComputedStyle(el).display === "none" || el.closest("[hidden]")) continue
          if ([...ancestors(el)].some(a => getComputedStyle(a).display === "none")) continue
          out.push(walker.currentNode.textContent.trim())
        }
        return out.filter(Boolean).join(" ")
        function* ancestors(el) { while (el) { yield el; el = el.parentElement } }
      })()
    JS
  end

  it "paints the landing's fanned cards in Classic, then Color-blind with marks, the same in both themes" do
    visit root_path
    expect_cards("main figure", classic, marks: false)
    colorblind!
    visit root_path
    expect_cards("main figure", colorblind, marks: true)
    light!
    visit root_path
    expect_cards("main figure", colorblind, marks: true)
  end

  it "paints How to play and names the Classic colors with no cookie" do
    visit how_to_play_path
    expect_cards("main", classic, marks: false)
    expect(captions).to eq(%w[red green purple])
    expect(page).to have_text("two red, one green")
    expect(page).to have_no_text("two blue, one orange")
    text = readable_text
    expect(text).to include("red green purple", "two red, one green")
    %w[blue orange magenta].each { |w| expect(text).not_to match(/\b#{w}\b/) }
  end

  it "paints How to play in Color-blind and names those colors under the cookie" do
    visit root_path
    colorblind!
    light!
    visit how_to_play_path
    expect_cards("main", colorblind, marks: true)
    expect(captions).to eq(%w[blue orange magenta])
    expect(page).to have_text("two blue, one orange")
    expect(page).to have_no_text("two red, one green")
    text = readable_text
    expect(text).to include("blue orange magenta", "two blue, one orange")
    %w[red green purple].each { |w| expect(text).not_to match(/\b#{w}\b/) }
  end
end
