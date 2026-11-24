require "rails_helper"

# SPEC §8 Big screen, Fit: the ended podium, headline and Play again stay inside the play area.
RSpec.describe "Big screen ended fit", type: :system do
  include_context "ended fit"

  FIT_SIZES.each do |w, h|
    it "fits at #{w}x#{h}" do
      resize(w, h)
      visit_big_screen
      expect_ended_fits
    end
  end
end
