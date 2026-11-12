require "rails_helper"

RSpec.describe "Player screen game over standings", type: :system do
  include_context "game over standings"

  [[375, 667], [667, 375], [1024, 640]].each do |width, height|
    it "keeps no page scroll with 8 players at #{width}x#{height}" do
      resize(width, height)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-standings] li", count: 8)
      scroll_height, inner_height, scroll_width, inner_width = page_scroll
      expect(scroll_height).to eq(inner_height)
      expect(scroll_width).to eq(inner_width)
      expect(page).to have_button("Play again")
    end
  end
end
