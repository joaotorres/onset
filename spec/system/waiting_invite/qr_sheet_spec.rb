require "rails_helper"

RSpec.describe "Player screen waiting invite", type: :system do
  include_context "waiting invite"

  describe "with a pointer and no Web Share" do
    include_context "waiting invite with a pointer and no Web Share"

    it "opens the QR sheet, closes it with Done, and a room update closes it" do
      click_button "Show QR"
      expect(sheet_open?).to be(true)
      within("dialog[data-invite-target=sheet]") do
        expect(page).to have_css("svg")
        expect(page).to have_content(game.code)
        click_button "Done"
      end
      expect(sheet_open?).to be(false)

      click_button "Show QR"
      expect(sheet_open?).to be(true)
      add_players(1)
      expect(page).to have_css("[data-roster] li", count: 3)
      expect(sheet_open?).to be(false)
      click_button "Show QR"
      expect(sheet_open?).to be(true)
    end
  end
end
