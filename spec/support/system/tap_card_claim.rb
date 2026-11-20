# Shared by the spec files in spec/system/tap_card_claim/.
RSpec.shared_context "tap card claim" do
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
    expect(page).to have_current_path(%r{\A/games/\w+/players/join\z})
    @code = current_path.split("/")[2]

    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_content("You're in")
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)

    game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current)
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

  def alice_claim = game.claims.find_by!(player: alice, result: :pending)

  # The picks reach the server by fetch, so poll until they land (§11).
  def expect_server_picks(ids)
    deadline = Time.current + Capybara.default_max_wait_time
    sleep 0.05 until alice_claim.card_ids == ids || Time.current > deadline
    expect(alice_claim.card_ids).to eq(ids)
  end

  def expect_picked(*ids)
    ids.each do |id|
      expect(page).to have_css("[data-card-id='#{id}'][aria-pressed='true'].ring-4")
    end
  end

  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }
end
