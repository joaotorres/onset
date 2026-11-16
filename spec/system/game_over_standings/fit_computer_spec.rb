require "rails_helper"

RSpec.describe "Player screen game over standings, computer", type: :system do
  include_context "game over standings"

  include_examples "game over standings fit", 1024, 640
end
