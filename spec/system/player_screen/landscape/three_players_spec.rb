require "rails_helper"

RSpec.describe "Player screen during play, landscape", type: :system do
  include_context "player screen"

  context "with 3 players and 12 cards" do
    include_context "player screen with 3 players and 12 cards", 667, 375

    it "fills the board's height with the cards" do
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-card-id]", count: 12)
      _, height = card_size
      expect(height).to be_within(3).of((board_height - 10) / 3.0)
      expect(board_overflow).to eq([0, 0])
    end

    it "calls SET! on an idle card tap and opens the claim block" do
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      find("[data-card-id='4']").click

      expect(page).to have_css("[data-claim-block]", text: "Your SET!")
      expect(find("[data-card-id='4']")["aria-pressed"]).to eq("true")
      counts = all("[data-card-selection-target='count']", visible: true).map(&:text)
      expect(counts).to eq(["1"])
      expect(page).to have_no_button("SET!")
      expect(overflow).to eq([0, 0, 0])
    end
  end
end
