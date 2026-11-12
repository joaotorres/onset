require "rails_helper"

RSpec.describe "Player screen during play, landscape", type: :system do
  include_context "player screen"

  context "with 8 players and 18 cards" do
    include_context "player screen with 8 players and 18 cards", 667, 375

    include_examples "fits the landscape screen", "locked out, wrong", "locked out, time's up"
  end
end
