require "rails_helper"

RSpec.describe "Tapping a card calls SET!", type: :system do
  include_context "tap card claim"

  context "when another player already holds the claim" do
    # Bob's claim lands in the database before Alice's tap, its broadcast after.
    before do
      game.claims.create!(player: bob, result: :pending, started_at: Time.current)
      game.update_columns(claim_player_id: bob.id, claim_started_at: Time.current)
    end

    it "creates no claim and shows someone else claiming" do
      card(4).click
      game.reload.send(:broadcast_game_state)

      expect(page).to have_content("is calling SET!")
      expect(game.claims.where(player: alice).count).to eq(0)
    end

    it "never pre-selects the lost tap in a later claim" do
      card(4).click
      game.reload.send(:broadcast_game_state)
      expect(page).to have_content("is calling SET!")

      game.claims.find_by!(player: bob).update!(result: :expired)
      game.release_claim!
      click_button "SET!"

      expect(page).to have_content("Your SET!")
      expect(page).to have_no_css("[aria-pressed='true']")
      expect(count_text).to all(eq("0"))
    end
  end
end
