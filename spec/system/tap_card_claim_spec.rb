require "rails_helper"

RSpec.describe "Tapping a card calls SET!", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.manage.window.resize_to(1280, 720)
  end

  let(:game) { Game.find_by!(code: @code) }
  let(:alice) { game.players.find_by!(name: "Alice") }
  let(:bob) { game.players.find_by!(name: "Bob") }

  # Board ids 0..11: 0, 1, 2 differ only in shading (a Set); 0, 1, 3 is not.
  before do
    visit root_path
    click_button "Start a game"
    expect(page).to have_current_path(%r{\A/games/\w+\z})
    @code = current_path.split("/").last

    visit join_game_players_path(@code)
    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_content("Waiting for players")
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)

    game.players.create!(name: "Bob", color: "#3498DB", last_seen_at: Time.current)
    game.start!
    game.update_columns(board: (0..11).to_a)
    # A fresh load: two broadcasts back to back can land out of order (§7).
    visit game_controller_path(@code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
    expect(page).to have_button("SET!")
    expect(page).to have_css("button[data-card-id='11']")
  end

  def card(id) = find("[data-card-id='#{id}']")

  def count_text = all("[data-card-selection-target='count']", visible: :all).map { |el| el.text(:all) }

  it "takes the claim and opens it with the tapped card selected" do
    card(4).click

    expect(page).to have_content("Your SET!")
    expect(card(4)[:class]).to include("ring-4")
    expect(card(4)["aria-pressed"]).to eq("true")
    expect(count_text).to all(eq("1"))
    expect(game.claims.where(player: alice, result: :pending).count).to eq(1)
  end

  it "scores a correct Set made from the tapped card and two more taps" do
    card(0).click
    expect(page).to have_content("Your SET!")
    card(1).click
    card(2).click

    expect(page).to have_no_content("Your SET!")
    expect(game.claims.find_by!(player: alice).reload).to be_correct
    expect(alice.reload.score).to eq(1)
  end

  it "scores a wrong Set as wrong and locks out" do
    card(0).click
    expect(page).to have_content("Your SET!")
    card(1).click
    card(3).click

    # Score never goes below 0 (Claim#resolve_wrong!), so check the result and the lockout.
    expect(page).to have_no_content("Your SET!")
    expect(game.claims.find_by!(player: alice).reload).to be_wrong
    expect(alice.reload).to be_locked
  end

  it "deselects the pre-selected card on a second tap" do
    card(4).click
    expect(page).to have_content("Your SET!")
    expect(card(4)["aria-pressed"]).to eq("true")

    card(4).click
    expect(card(4)["aria-pressed"]).to eq("false")
    expect(count_text).to all(eq("0"))
  end

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
