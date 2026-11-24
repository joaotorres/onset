require "rails_helper"

# SPEC §10 Visual system, Text: a locked player's entry on the player
# screen's scoreboard reads at 4.5:1 or more, in dark.
RSpec.describe "Locked entries on the player screen's scoreboard, dark", type: :system do
  include_context "locked entry"

  it "draws the locked name and score in muted, own entry gray-400, unfaded" do
    dark_device!
    expect_locked_entries(plain: muted, own: color("gray-400"))
  end
end
