require "rails_helper"

RSpec.describe "Player screen waiting invite", type: :system do
  include_context "waiting invite"

  describe "with 8 players" do
    before do
      join_as("Bartholomew Ashworth")
      add_players(7)
    end

    [[375, 667], [667, 375], [1024, 640]].each do |width, height|
      it "keeps no page scroll at #{width}x#{height}, sheet closed and open" do
        resize(width, height)
        visit game_controller_path(game.code)
        expect(page).to have_css("[data-roster] li", count: 8)
        expect(page).to have_button("I'm ready")
        expect_no_page_scroll

        click_button "Show QR"
        expect(sheet_open?).to be(true)
        expect_no_page_scroll
        fits = page.evaluate_script("(() => { const r = document.querySelector('dialog[data-invite-target=sheet]').getBoundingClientRect(); return r.top >= 0 && r.bottom <= window.innerHeight && r.left >= 0 && r.right <= window.innerWidth; })()")
        expect(fits).to be(true)
      end
    end
  end
end
