require "rails_helper"

# SPEC §10 Visual system, Text: a locked player's entry on the player
# screen's scoreboard reads at 4.5:1 or more, in light.
RSpec.describe "Locked entries on the player screen's scoreboard, light", type: :system do
  include_context "locked entry"

  it "draws the locked name and score in gray-500, own entry gray-600, unfaded" do
    light!
    expect_locked_entries(plain: color("gray-500"), own: color("gray-600"))
  end
end
