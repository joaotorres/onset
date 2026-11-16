require "rails_helper"

RSpec.describe "Player screen game over standings, portrait", type: :system do
  include_context "game over standings"

  include_examples "game over standings fit", 375, 667
end
