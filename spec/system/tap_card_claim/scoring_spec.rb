require "rails_helper"

RSpec.describe "Tapping a card calls SET!", type: :system do
  include_context "tap card claim"

  it "scores a correct Set made from the tapped card and two more taps" do
    card(0).click
    expect(page).to have_content("Your SET!")
    card(1).click
    card(2).click
    expect_server_picks([0, 1, 2])
    expect(page).to have_content("Your SET!")

    ExpireClaimJob.perform_now(alice_claim)
    expect(page).to have_no_content("Your SET!")
    expect(game.claims.find_by!(player: alice).reload).to be_correct
    expect(alice.reload.score).to eq(1)
  end

  it "scores a wrong Set as wrong and locks out" do
    card(0).click
    expect(page).to have_content("Your SET!")
    card(1).click
    card(3).click
    expect_server_picks([0, 1, 3])
    expect(page).to have_content("Your SET!")

    ExpireClaimJob.perform_now(alice_claim)
    # Score never goes below 0 (Claim#resolve_wrong!), so check the result and the lockout.
    expect(page).to have_no_content("Your SET!")
    expect(game.claims.find_by!(player: alice).reload).to be_wrong
    expect(alice.reload).to be_locked
  end
end
