require "rails_helper"

# A pick still on its way when the player screen redraws mid-claim (§11):
# the redrawn screen keeps the latest picks and the requests stay one at a time.
RSpec.describe "Picks across a redraw", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.manage.window.resize_to(420, 900)
  end

  def setup_claim_state
    visit root_path
    click_button "Start a game"
    expect(page).to have_current_path(%r{\A/games/\w+/players/join\z})
    game_code = current_path.split("/")[2]

    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"

    game = Game.find_by!(code: game_code)
    game.start!

    player = game.players.find_by!(name: "Alice")
    claim = game.claims.create!(player: player, result: :pending, started_at: Time.current)
    game.update!(claim_player_id: player.id, claim_started_at: Time.current)

    visit game_controller_path(game_code)
    expect(page).to have_css("[data-controller='card-selection']")
    claim
  end

  # Wraps window.fetch so each PATCH waits until release_picks! lets it go,
  # and counts how many are on their way at once.
  def hold_picks!
    page.execute_script(<<~JS)
      window.__held = []
      window.__holding = true
      window.__inFlight = 0
      window.__maxInFlight = 0
      window.__done = 0
      const original = window.fetch
      window.fetch = (url, options) => {
        if (!options || options.method !== "PATCH") return original(url, options)
        window.__inFlight++
        window.__maxInFlight = Math.max(window.__maxInFlight, window.__inFlight)
        const go = () => original(url, options).finally(() => { window.__inFlight--; window.__done++ })
        if (!window.__holding) return go()
        return new Promise(resolve => window.__held.push(resolve)).then(go)
      }
    JS
  end

  def release_picks!
    page.execute_script("window.__holding = false; window.__held.splice(0).forEach(r => r())")
  end

  def wait_for_picks_sent(count)
    deadline = Time.current + Capybara.default_max_wait_time
    sleep 0.05 until page.evaluate_script("window.__done") >= count || Time.current > deadline
    expect(page.evaluate_script("window.__done")).to eq(count)
  end

  def redraw!(game)
    page.execute_script("document.getElementById('controller_status').dataset.beforeRedraw = 'yes'")
    game.update!(flash_claim_id: nil)
    expect(page).to have_no_css("#controller_status[data-before-redraw]")
  end

  def tap(id) = find("[data-card-id='#{id}']").click

  def expect_picks(ids, board)
    ids.each { |id| expect(page).to have_css("[data-card-id='#{id}'][aria-pressed='true'].ring-4") }
    (board - ids).each { |id| expect(page).to have_css("[data-card-id='#{id}'][aria-pressed='false']") }
    expect(page).to have_css("[data-card-selection-target='count']", text: ids.size.to_s)
    expect(page).to have_css("[data-slot-card-id]", count: ids.size)
    ids.each { |id| expect(page).to have_css("[data-slot-card-id='#{id}'] svg") }
  end

  it "shows a pick still on its way and the one after it on the redrawn screen" do
    claim = setup_claim_state
    game = claim.game
    a, b = game.board.first(2)
    hold_picks!

    tap(a)
    tap(b)
    redraw!(game)

    expect_picks([a, b], game.board)
    release_picks!
    wait_for_picks_sent(2)
    expect(claim.reload.card_ids).to eq([a, b])
    expect_picks([a, b], game.board)
  end

  it "sends one pick request at a time across the redraw" do
    claim = setup_claim_state
    game = claim.game
    a, b = game.board.first(2)
    hold_picks!

    tap(a)
    redraw!(game)
    tap(b)

    expect_picks([a, b], game.board)
    release_picks!
    wait_for_picks_sent(2)
    expect(page.evaluate_script("window.__maxInFlight")).to eq(1)
    expect(claim.reload.card_ids).to eq([a, b])
    expect_picks([a, b], game.board)
  end

  it "unpicks on the redrawn screen a pick still on its way" do
    claim = setup_claim_state
    game = claim.game
    a = game.board.first
    hold_picks!

    tap(a)
    redraw!(game)
    tap(a)

    expect_picks([], game.board)
    release_picks!
    wait_for_picks_sent(2)
    expect(claim.reload.card_ids).to eq([])
    expect_picks([], game.board)
  end
end
