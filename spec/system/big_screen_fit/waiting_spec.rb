require "rails_helper"

# SPEC §8 Big screen, Fit: the waiting hero, pills and Start game stay inside the play area, windows under 800px tall.
RSpec.describe "Big screen waiting fit", type: :system do
  include_context "waiting fit"

  FIT_SIZES.select { |_, h| h < 800 }.each do |w, h|
    it "fits at #{w}x#{h}" do
      resize(w, h)
      visit_big_screen
      expect_waiting_fits
    end
  end
end
