require "rails_helper"

RSpec.describe "Landing layout", type: :system do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def rect(selector)
    page.evaluate_script("(() => { const r = document.querySelector(#{selector.to_json}).getBoundingClientRect(); return {left: r.left, right: r.right, top: r.top, bottom: r.bottom, width: r.width, height: r.height}; })()")
  end

  # The h1 is a block as wide as its column: measure the text itself.
  def wordmark_right
    page.evaluate_script("(() => { const r = document.createRange(); r.selectNodeContents(document.querySelector('h1')); return r.getBoundingClientRect().right; })()")
  end

  # The first card's wrapper (the landing cards carry no data-card-id). Tilted: its layout size, not the rotated box.
  def card_size
    page.evaluate_script("(() => { const c = document.querySelector('figure div > div'); return [c.offsetWidth, c.offsetHeight]; })()")
  end

  def horizontal_scroll
    page.evaluate_script("document.documentElement.scrollWidth - window.innerWidth")
  end

  def visit_at(width)
    resize(width, 900)
    visit root_path
    expect(page).to have_css("h1", text: "Onset")
  end

  [800, 768].each do |width|
    it "stacks in one column at #{width}px" do
      visit_at(width)
      expect(rect("figure")["top"]).to be >= rect("section")["bottom"]
      expect(rect("section")["top"]).to be >= rect("header")["bottom"]
      expect(horizontal_scroll).to eq(0)
    end
  end

  [1024, 1100].each do |width|
    it "keeps the brand column clear of the actions card at #{width}px" do
      visit_at(width)
      section = rect("section")
      expect(section["top"]).to be < rect("figure")["top"]
      expect(rect("figure div")["right"]).to be <= section["left"]
      expect(wordmark_right).to be <= section["left"]
      expect(horizontal_scroll).to eq(0)
    end
  end

  it "keeps the cards' 5:7 shape as they shrink" do
    visit_at(1024)
    width, height = card_size
    expect(height).to be < 192
    expect(width.to_f / height).to be_within(0.02).of(5.0 / 7)
  end

  it "measures as the desktop design at 1280px" do
    visit_at(1280)
    expect(card_size.last).to be_within(1).of(192)
    expect(page.evaluate_script("getComputedStyle(document.querySelector('h1')).fontSize")).to eq("136px")
    expect(rect("section")["width"]).to be_within(0.5).of(448)
    expect(wordmark_right).to be <= rect("section")["left"]
  end

  it "keeps the phone layout at 375px" do
    visit_at(375)
    expect(card_size.last).to be_within(1).of(80)
    expect(rect("figure")["top"]).to be >= rect("section")["bottom"]
    expect(horizontal_scroll).to eq(0)
  end
end
