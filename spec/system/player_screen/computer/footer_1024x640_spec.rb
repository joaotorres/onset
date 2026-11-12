require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  include_context "player screen"

  context "with the Room CODE footer" do
    before { start_with(PlayerScreenStates::EIGHT_NAMES.first(3), cards: 18) }

    include_examples "centres the footer on the board", 1024, 640
  end
end
