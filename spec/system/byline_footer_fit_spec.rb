require "rails_helper"

RSpec.describe "Byline footer fit", type: :system do
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

  def rect(selector)
    page.evaluate_script("(() => { const r = document.querySelector(#{selector.to_json}).getBoundingClientRect(); return {top: r.top + scrollY, bottom: r.bottom + scrollY, height: r.height}; })()")
  end

  def scroll_height = page.evaluate_script("document.documentElement.scrollHeight")

  def inner_height = page.evaluate_script("window.innerHeight")

  def expect_footer_below_main
    expect(rect("footer.byline-footer")["top"]).to be >= rect("body > main")["bottom"] - 0.5
  end

  def expect_fits_screen
    expect(scroll_height).to be <= inner_height
    footer = rect("footer.byline-footer")
    expect(footer["bottom"]).to be <= inner_height + 0.5
    # The column fills the screen: the footer touches the bottom edge.
    expect(footer["bottom"]).to be_within(0.5).of(inner_height)
    expect_footer_below_main
  end

  [[1280, 800], [1024, 900]].each do |width, height|
    context "at #{width}x#{height}" do
      before { resize(width, height) }

      it "fits the landing on one screen, its content centred in main" do
        visit root_path
        expect(page).to have_css("h1", text: "Onset")
        expect_fits_screen
        main = rect("body > main")
        content = rect("body > main > *")
        expect((content["top"] + content["bottom"]) / 2).to be_within(1).of((main["top"] + main["bottom"]) / 2)
      end

      it "fits the join page on one screen, the Join button last in main" do
        visit join_game_players_path(game.code)
        expect(page).to have_button("Join")
        expect_fits_screen
        expect(rect("input[type=submit][value=Join]")["bottom"]).to be <= rect("body > main")["bottom"]
      end

      it "puts the footer directly after How to play's content" do
        visit how_to_play_path
        expect(page).to have_css("footer.byline-footer")
        main = rect("body > main")
        footer = rect("footer.byline-footer")
        expect(main["height"]).to be > inner_height
        expect(footer["top"]).to be_within(0.5).of(main["bottom"])
        expect(scroll_height).to be_within(1).of(main["height"] + footer["height"])
      end
    end
  end

  it "keeps the big screen full height with no footer" do
    resize(1280, 800)
    visit game_path(game.code)
    expect(page).to have_css("body > main")
    expect(page).to have_no_css("footer.byline-footer")
    expect(rect("body > main")["height"]).to be_within(0.5).of(inner_height)
    expect(scroll_height).to be <= inner_height
  end
end
