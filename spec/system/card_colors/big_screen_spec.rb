require "rails_helper"

# SPEC §10 Palette on the big screen: the board and the announcement band's
# found Set paint in the palette in force, the same in both themes.
RSpec.describe "Card colors on the big screen", type: :system do
  include_context "big screen theme"
  include_context "card colors"

  before do
    alice, bob = add_players(2)
    game.start!
    game.update!(board: [0, 9, 18, 1, 10, 19, 2, 11, 20, 3, 12, 21])
    claim = game.claims.create!(player: bob, result: :correct, card_ids: [0, 9, 18], started_at: Time.current, resolved_at: Time.current)
    game.update!(flash_claim_id: claim.id)
    alice.touch
  end

  it "paints Classic with no cookie and Color-blind with its marks under the cookie, in both themes" do
    visit_big_screen
    expect_cards("#board", classic, marks: false)
    expect_cards("#announcement", classic, marks: false)

    colorblind!
    visit_big_screen
    expect_cards("#board", colorblind, marks: true)
    expect_cards("#announcement", colorblind, marks: true)

    light!
    visit_big_screen
    expect_cards("#board", colorblind, marks: true)
    expect_cards("#announcement", colorblind, marks: true)
  end
end
