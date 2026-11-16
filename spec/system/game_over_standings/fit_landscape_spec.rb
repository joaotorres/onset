require "rails_helper"

RSpec.describe "Player screen game over standings, landscape", type: :system do
  include_context "game over standings"

  include_examples "game over standings fit", 667, 375
end
