require "rails_helper"

# SPEC §8 Settings menu and Big screen: the settings button bottom-right in
# waiting, playing and ended, with no page scroll and the grid and band at
# their sizes.
RSpec.describe "Settings button on the big screen", type: :system do
  include_context "big screen theme"

  def card_height = rect("#board .grid > div")["height"]

  def expect_states_fit
    add_players(8)
    visit_big_screen
    expect(page).to have_content("Start game")
    expect_settings_in_corner

    game.start!
    game.update!(board: (0..17).to_a, deck: (18..80).to_a)
    game.try_claim!(game.players.first)
    expect(page).to have_content("is calling SET!")
    expect(page).to have_css("#board .grid > div", count: 18)
    expect_settings_in_corner
    with_button = [card_height, rect("#announcement")["height"]]
    page.execute_script("document.querySelector('main > [data-controller=settings]').remove()")
    expect([card_height, rect("#announcement")["height"]]).to eq(with_button)

    visit_big_screen
    game.update!(status: :ended)
    expect(page).to have_button("Play again")
    expect_settings_in_corner
  end

  it "sits in the corner in every state at 1280x800" do
    resize(1280, 800)
    expect_states_fit
  end

  it "sits in the corner in every state at 1920x1080" do
    resize(1920, 1080)
    expect_states_fit
  end
end
