require "rails_helper"

RSpec.describe "Player screen during play, portrait", type: :system do
  include_context "player screen"

  context "with 8 players and 18 cards" do
    include_context "player screen with 8 players and 18 cards", 375, 667

    include_examples "fits the portrait screen", "No Set countdown", "No Set countdown, agreed"
  end
end
