require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  include_context "player screen"

  context "with 3 players and 12 cards" do
    include_context "player screen with 3 players and 12 cards", 1024, 640

    it "calls SET! on an idle card tap and opens the claim block at 1/3" do
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      find("[data-card-id='4']").click

      expect(page).to have_css("[data-claim-block]", text: "Your SET!")
      expect(find("[data-card-id='4']")["aria-pressed"]).to eq("true")
      counts = all("[data-card-selection-target='count']", visible: true).map(&:text)
      expect(counts).to eq(["1"])
      expect(page).to have_no_button("SET!")
      expect(page).to have_no_css("[data-card-selection-target='slot']", visible: true)
      expect(overflow).to eq([0, 0, 0])
    end

    it "uses the computer layout in a 1024x1366 portrait viewport" do
      resize(1024, 1366)
      visit game_controller_path(game.code)
      expect_computer_layout
      expect(overflow).to eq([0, 0, 0])
    end

    it "keeps the landscape layout at 1023x640" do
      resize(1023, 640)
      visit game_controller_path(game.code)
      lefts = column_lefts
      expect(lefts).to eq(lefts.sort)
      expect(rect("[data-scoreboard]")["width"]).to be_within(1).of(132)
      expect(overflow).to eq([0, 0, 0])
    end
  end
end
