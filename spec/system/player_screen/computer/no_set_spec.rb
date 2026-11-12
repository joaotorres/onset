require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  include_context "player screen"

  context "with 8 players and 18 cards" do
    include_context "player screen with 8 players and 18 cards", 1024, 640

    include_examples "fits the computer screen", "No Set countdown", "No Set countdown, agreed"
  end
end
