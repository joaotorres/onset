# Shared by spec/system/big_screen_theme/: the settings button and the light
# theme on the big screen (SPEC §8 Settings menu, Big screen; §10 Themes).
RSpec.shared_context "big screen theme" do
  include_context "resizable window"
  include_context "settings menu"

  let(:game) { Game.create! }

  def settings_button = find('button[aria-label="Settings"]')
  def menu_open? = page.has_css?("#settings_menu", visible: true, wait: 0)

  def light!
    page.driver.browser.manage.add_cookie(name: "theme", value: "light", path: "/")
  end

  def add_players(count)
    Player::PRESET_COLORS.first(count).each_with_index.map do |color, i|
      game.players.create!(name: "Player #{i + 1}", color: color, last_seen_at: Time.current)
    end
  end

  def visit_big_screen
    visit game_path(game.code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
  end

  def shadow(selector) = style(selector, "box-shadow")

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

  # The button 56x56 in the bottom-right corner, 40px in from both edges,
  # outside every broadcast target, and the page does not scroll.
  def expect_settings_in_corner
    expect(page).to have_css('main > [data-controller=settings] > button[aria-label="Settings"]', visible: true)
    button = rect('button[aria-label="Settings"]')
    width, height = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    expect([button["width"], button["height"]]).to eq([56, 56])
    expect(width - button["right"]).to be_within(1).of(40)
    expect(height - button["bottom"]).to be_within(1).of(40)
    scroll_height, inner_height, scroll_width, inner_width = page_scroll
    expect([scroll_height, scroll_width]).to eq([inner_height, inner_width])
  end
end
