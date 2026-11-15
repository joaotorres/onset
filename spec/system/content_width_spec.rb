require "rails_helper"

# SPEC.md, Shared: 8. Views & UX, Width: a content page holds its content in a
# centred 944px box inside a 20/32/40px gutter; the byline footer shares it.
RSpec.describe "Content page width", type: :system do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def box(selector)
    page.evaluate_script("(() => { const r = document.querySelector(#{selector.to_json}).getBoundingClientRect(); return {left: r.left, width: r.width}; })()")
  end

  def page_width = page.evaluate_script("document.documentElement.clientWidth")

  def content = box("main .max-w-\\[944px\\]")

  def footer = box("footer.byline-footer .max-w-\\[944px\\]")

  it "is 944px and centred at 1280px wide, the footer lined up with it" do
    resize(1280, 800)
    visit how_to_play_path
    w = page_width
    expect(content["width"]).to be_within(0.5).of(944)
    expect(content["left"]).to be_within(0.5).of((w - 944) / 2.0)
    expect(footer["left"]).to be_within(0.5).of(content["left"])
    expect(footer["width"]).to be_within(0.5).of(content["width"])
  end

  it "keeps 32px gutters at 800px wide, the footer lined up with it" do
    resize(800, 800)
    visit how_to_play_path
    expect(content["width"]).to be_within(0.5).of(page_width - 64)
    expect(content["left"]).to be_within(0.5).of(32)
    expect(footer["left"]).to be_within(0.5).of(content["left"])
    expect(footer["width"]).to be_within(0.5).of(content["width"])
  end

  it "keeps 20px gutters at 375px wide" do
    resize(375, 800)
    visit how_to_play_path
    expect(content["width"]).to be_within(0.5).of(page_width - 40)
    expect(content["left"]).to be_within(0.5).of(20)
  end

  it "leaves the big screen and the player screen without the box" do
    visit root_path
    click_button "Start a game"
    expect(page).to have_current_path(%r{\A/games/\w+/players/join\z})
    game_code = current_path.split("/")[2]
    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game_code))
    expect(page.html).not_to include("max-w-[944px]")

    visit game_path(game_code)
    expect(page).to have_css("body > main")
    expect(page.html).not_to include("max-w-[944px]")
  end
end
