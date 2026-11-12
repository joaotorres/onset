require "rails_helper"

RSpec.describe "Submitting a claim", type: :system do
  include_context "claim submit"

  context "with 8 players and 18 cards" do
    include_context "claim submit with 8 players and 18 cards"

    include_examples "keeps no page scroll during a claim", 1024, 640
  end
end
