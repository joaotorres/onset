require "rails_helper"

# SPEC.md §6, Server-side timers: countdowns follow the server's clock.
RSpec.describe "Countdown follows the server's clock", type: :system do
  before { driven_by :selenium, using: :headless_chrome }

  def setup_claim_state
    visit root_path
    click_button "Start a game"
    expect(page).to have_current_path(%r{\A/games/\w+/players/join\z})
    game_code = current_path.split("/")[2]

    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game_code))

    game = Game.find_by!(code: game_code)
    game.start!
    player = game.players.find_by!(name: "Alice")
    game.claims.create!(player: player, result: :pending, started_at: Time.current)
    game.update!(claim_player_id: player.id, claim_started_at: Time.current)

    visit game_controller_path(game_code)
    expect(page).to have_css("[data-countdown-target='display']")
    game
  end

  # Skews Date.now by the given ms, then asks the clock module for a fresh offset.
  def skew_clock_and_sync(ms)
    page.execute_script(<<~JS)
      const realNow = Date.now.bind(Date)
      Date.now = () => realNow() + (#{ms})
    JS
    page.evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1]
      import("server_clock").then(m => m.sync()).then(() => done(true), () => done(false))
    JS
  end

  def display_seconds = find("[data-countdown-target='display']").text.to_i

  def expect_true_time_left
    sleep 0.1 # a few animation frames
    expect(display_seconds).to be_between(1, Game::CLAIM_TIMEOUT)
  end

  it "shows the true time left with the device clock 60 s ahead" do
    setup_claim_state
    skew_clock_and_sync(60_000)
    expect_true_time_left
  end

  it "shows no more than the claim timeout with the device clock 60 s behind" do
    setup_claim_state
    skew_clock_and_sync(-60_000)
    sleep 0.1
    expect(display_seconds).to be <= Game::CLAIM_TIMEOUT
    expect(display_seconds).to be >= 1
  end

  it "keeps the offset across a redraw" do
    game = setup_claim_state
    skew_clock_and_sync(60_000)

    page.execute_script("document.getElementById('controller_status').dataset.beforeRedraw = 'yes'")
    game.update!(flash_claim_id: nil)
    expect(page).to have_no_css("#controller_status[data-before-redraw]")

    expect_true_time_left
  end
end
