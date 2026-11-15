require "rails_helper"

# SPEC §10 Palette on the player screen: the board, the portrait tray and the
# found-set banner paint in the palette in force, with the marks under Color-blind.
RSpec.describe "Card colors on the player screen", type: :system do
  include_context "player screen"
  include_context "card colors"
  include_context "player screen with 3 players and 12 cards", 375, 667

  before { game.update!(board: [0, 9, 18, 1, 10, 19, 2, 11, 20, 3, 12, 21]) }

  def fill_tray
    game.try_claim!(me)
    visit game_controller_path(game.code)
    [0, 9, 18].each { |id| find("[data-card-id='#{id}']").click }
    expect(page).to have_css("[data-tray] [data-slot-card-id] svg", count: 3)
  end

  def show_banner
    play_state("found-set banner")
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-found-banner] svg", count: 3)
  end

  it "paints Classic with no cookie: board, tray and found-set banner, no marks" do
    visit game_controller_path(game.code)
    expect_cards("[data-board]", classic, marks: false)
    fill_tray
    expect_cards("[data-tray]", classic, marks: false)
    game.release_claim!
    show_banner
    expect_cards("[data-found-banner]", classic, marks: false)
  end

  it "paints Color-blind with the marks under card_colors=colorblind, the same in both themes" do
    visit root_path
    colorblind!
    visit game_controller_path(game.code)
    expect_cards("[data-board]", colorblind, marks: true)
    light!
    visit game_controller_path(game.code)
    expect_cards("[data-board]", colorblind, marks: true)
    fill_tray
    expect_cards("[data-tray]", colorblind, marks: true)
    game.release_claim!
    show_banner
    expect_cards("[data-found-banner]", colorblind, marks: true)
  end
end
