require "rails_helper"

RSpec.describe "Submitting a claim", type: :system do
  include_context "claim submit"

  context "in portrait" do
    include_context "claim submit in portrait"

    it "keeps the tray and Submit at 176px so the board does not move" do
      visit game_controller_path(game.code)
      expect(page).to have_button("SET!")
      board = rect("[data-board]")
      claim!
      expect(rect("[data-board]")).to eq(board)
      tray = rect("[data-tray]")
      expect(tray["height"]).to eq(128)
      pill = rect("[data-pill-slot]")
      expect(pill["height"]).to eq(44)
      expect(pill["top"] + pill["height"] - tray["top"]).to eq(176)
      slot = rect("[data-card-selection-target='slot']")
      expect([slot["width"], slot["height"].round]).to eq([72, 101])
    end
  end
end
