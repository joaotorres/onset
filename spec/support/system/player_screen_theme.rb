# Shared by spec/system/player_screen_theme/: the settings button and the
# light theme on the player screen (SPEC §8 Settings menu, §10 Themes).
RSpec.shared_context "player screen theme" do
  include_context "player screen"
  include_context "settings menu"

  def settings_button = find('button[aria-label="Settings"]')

  def light!
    page.driver.browser.manage.add_cookie(name: "theme", value: "light", path: "/")
  end

  # The computed value of a Tailwind color at an opacity, as Tailwind mixes it.
  def mix(name, percent)
    page.evaluate_script(<<~JS)
      (() => {
        const probe = document.createElement("div")
        probe.style.backgroundColor = "color-mix(in oklab, var(--color-#{name}) #{percent}%, transparent)"
        document.body.append(probe)
        const value = getComputedStyle(probe).backgroundColor
        probe.remove()
        return value
      })()
    JS
  end

  # The settings button sits in the "Room CODE" footer row, outside
  # #controller_status, at the given size, and the screen keeps its fit.
  # right: the button's distance from the viewport's right edge.
  def expect_settings_in_footer(right:, width: 40, height: 28)
    expect(page).to have_css('button[aria-label="Settings"]', visible: true)
    expect(page).to have_no_css('#controller_status button[aria-label="Settings"]')
    button = rect('button[aria-label="Settings"]')
    footer = rect("main > p")
    expect([button["width"], button["height"]]).to eq([width, height])
    footer_middle = (footer["top"] + footer["bottom"]) / 2
    expect(footer_middle).to be_between(button["top"], button["bottom"])
    expect(page.evaluate_script("window.innerWidth") - button["right"]).to be_within(1).of(right)
    expect(button["bottom"]).to be <= page.evaluate_script("window.innerHeight")
    expect(overflow).to eq([0, 0, 0])
  end

  # The card size is the one the screen had before the settings button: taking
  # the button out of the page changes nothing.
  def expect_card_size_unchanged(state)
    with_button = card_size
    page.execute_script("document.querySelector('[data-controller=settings]').remove()")
    expect(card_size).to eq(with_button), state
  end

  # One state after another in one example: back to idle first.
  def play_state!(name)
    game.reload.update!(claim_player_id: nil, claim_started_at: nil, no_set_caller_id: nil, no_set_started_at: nil,
      no_set_refuser_id: nil, no_set_refused_at: nil, no_set_voters: [], flash_claim_id: nil, last_dealt: [])
    me.update!(locked_until: nil)
    play_state(name)
  end

  # States played through on each layout.
  def play_states = ["idle", "claiming (mine)", "someone else claiming", "No Set blocked", "found-set banner"]

  # Waiting and game over with the same 8 players.
  def waiting! = game.update!(status: :waiting, board: [], deck: [])

  def game_over!
    game.players.order(:id).zip([6, 7, 4, 3, 2, 3, 1, 0]).each { |p, s| p.update!(score: s) }
    game.update!(status: :ended, board: [], deck: [], discard: [])
  end
end

# Shared by the disabled_pills_*_spec.rb files in spec/system/player_screen_theme/.
RSpec.shared_context "disabled pills" do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  let(:panel) { "[data-status-slot] [role=status]" }
  let(:pill) { "[data-pill-slot] button[disabled]" }
end
