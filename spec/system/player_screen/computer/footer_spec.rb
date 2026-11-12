require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  include_context "player screen"

  context "with the Room CODE footer" do
    before { start_with(PlayerScreenStates::EIGHT_NAMES.first(3), cards: 18) }

    it "keeps the footer on the board after a Turbo update" do
      resize(1024, 640)
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      game.try_claim!(other)
      expect(page).to have_css("[aria-label=\"SET! unavailable, #{other.name} is claiming\"]")
      expect_footer_on_board
    end

    it "keeps the footer centred on the screen at 375x667 and 667x375" do
      [[375, 667], [667, 375]].each do |width, height|
        resize(width, height)
        visit game_controller_path(game.code)
        expect(page).to have_css("[data-card-id]", count: 18)
        expect(centre("main > p")).to be_within(1).of(page.evaluate_script("window.innerWidth") / 2.0)
      end
    end
  end

  it "keeps the footer centred on the screen while waiting" do
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: "Ada"
    all("label.cursor-pointer").first.click
    click_button "Join"
    resize(1024, 640)
    expect(page).to have_text("You're in")
    expect(centre("main > p")).to be_within(1).of(512)
  end
end
