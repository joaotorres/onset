require "rails_helper"

# Custom events reach jtTrack in the browser. PostHog never loads in test, so
# a stand-in posthog, installed before any page script, records what jtTrack
# forwards. The game state events come from the player at the top of the
# standings only: at the start, with every score 0, the first to join.
RSpec.describe "Telemetry", type: :system do
  before { driven_by :selenium, using: :headless_chrome }

  def on(session, &) = Capybara.using_session(session, &)

  def record_events
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
      window.tracked = []
      window.posthog = { capture: (name, props) => window.tracked.push([name, props]) }
    JS
  end

  def tracked = page.evaluate_script("window.tracked")
  def tracked_names = tracked.map(&:first)

  def join(name, swatch)
    fill_in "player[name]", with: name
    all("label.cursor-pointer")[swatch].click
    click_button "Join"
    expect(page).to have_content("You're in")
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
  end

  it "sends each game event once, from one screen" do
    on("phone1") do
      record_events
      visit root_path
      click_button "Start a game"
      expect(page).to have_content("Joining room")
      expect(tracked).to eq([["game_created", {"mode" => "standard"}]])
      join("Alice", 0)
      expect(tracked.last).to eq(["player_joined", {"player_count" => 1, "is_creator" => true, "mode" => "standard"}])
    end
    game = Game.last

    on("phone2") do
      record_events
      visit join_game_players_path(game.code)
      join("Bob", 1)
      expect(tracked).to eq([["player_joined", {"player_count" => 2, "is_creator" => false, "mode" => "standard"}]])
    end

    on("phone1") { click_button "I'm ready" }
    on("phone2") { click_button "I'm ready" }
    on("phone1") { expect(page).to have_button("SET!") }
    on("phone2") { expect(page).to have_button("SET!") }
    on("phone1") { expect(tracked.last).to eq(["game_started", {"mode" => "standard", "player_count" => 2}]) }

    game.reload.update!(status: :ended)
    on("phone1") do
      expect(page).to have_button("Play again")
      name, props = tracked.last
      expect(name).to eq("game_finished")
      expect(props).to include("mode" => "standard", "player_count" => 2, "end_reason" => "deck_exhausted", "is_tie" => true)
      expect(props["duration_seconds"]).to be_between(0, 60)
    end

    on("phone1") { click_button "Play again" }
    on("phone2") { click_button "Play again" }
    on("phone1") do
      expect(page).to have_button("SET!")
      expect(tracked_names).to eq(%w[game_created player_joined game_started game_finished game_restarted])
    end
    on("phone2") do
      expect(page).to have_button("SET!")
      expect(tracked_names).to eq(%w[player_joined])
    end
  end
end
