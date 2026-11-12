require "rails_helper"

RSpec.describe "Player screen during play, portrait", type: :system do
  include_context "player screen"

  context "with 3 players and 12 cards" do
    include_context "player screen with 3 players and 12 cards", 375, 667

    it "makes the cards larger" do
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-card-id]", count: 12)
      width, height = card_size
      expect(width).to be >= 65
      expect(height).to be_within(2).of(width * 7 / 5)
      expect(overflow).to eq([0, 0, 0])
    end

    it "opens the claim at 1/3 with the tapped card selected" do
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      find("[data-card-id='4']").click

      expect(page).to have_content("Your SET!")
      expect(find("[data-card-id='4']")["aria-pressed"]).to eq("true")
      counts = all("[data-card-selection-target='count']", visible: true).map(&:text)
      expect(counts).to eq(["1"])
      expect(overflow).to eq([0, 0, 0])
    end
  end
end
