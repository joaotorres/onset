# Shared by the spec files in spec/system/claim_submit/. Submit during the
# player's own claim (§8 Player screen 3, §11): enabled at exactly three picks,
# sent at once with the whole selection, the screen frozen until the resolving
# broadcast replaces it.
RSpec.shared_context "claim submit" do
  include_context "resizable window"

  let(:game) { Game.create! }
  let(:me) { game.players.order(:id).first }

  def overflow
    page.evaluate_script(<<~JS)
      (() => {
        const d = document.documentElement, m = document.querySelector("main")
        return [d.scrollHeight - window.innerHeight, d.scrollWidth - window.innerWidth, m.scrollHeight - m.clientHeight]
      })()
    JS
  end

  # The first visible match: the tray and pill slot exist once per layout.
  def rect(selector)
    page.evaluate_script("(() => { const r = [...document.querySelectorAll(#{selector.to_json})].find(e => e.offsetParent).getBoundingClientRect(); return {top: r.top, height: r.height, width: r.width}; })()")
  end

  def join(names: ["Alice"], cards: 12)
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: names.first
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game.code))
    taken = game.players.pluck(:color)
    names.drop(1).zip(PlayersController::PRESET_COLORS - taken).each do |name, color|
      game.players.create!(name: name, color: color, last_seen_at: Time.current)
    end
    game.start!
    game.update!(board: (0...cards).to_a, deck: (cards..80).to_a)
  end

  def claim!
    claim = game.try_claim!(me)
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-controller='card-selection']")
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
    claim
  end

  def set_ids = game.board_cards.combination(3).find { |trio| Card.valid_set?(*trio) }.map(&:id)

  def non_set_ids = game.board_cards.combination(3).find { |trio| !Card.valid_set?(*trio) }.map(&:id)

  def tap(id) = find("[data-card-id='#{id}']").click

  def submit_button = find("[data-card-selection-target='submit']", visible: true)

  def hint = all("[data-card-selection-target='hint']", visible: true).map(&:text)

  # Holds PATCH and POST fetches until release! lets them go, and records each
  # one; with fail_submits the submit POST rejects as a lost request would, and
  # with fail_submits: :held it waits for fail_submits! to reject it.
  def hold_requests!(fail_submits: false)
    page.execute_script(<<~JS)
      window.__held = []
      window.__heldSubmits = []
      window.__sent = []
      const original = window.fetch
      window.fetch = (url, options) => {
        if (!options || !["PATCH", "POST"].includes(options.method)) return original(url, options)
        window.__sent.push({ url: String(url), method: options.method, body: options.body })
        if (#{(fail_submits == :held).to_json} && String(url).endsWith("/submit")) {
          return new Promise((_resolve, reject) => window.__heldSubmits.push(() => reject(new TypeError("Failed to fetch"))))
        }
        if (#{(fail_submits == true).to_json} && String(url).endsWith("/submit")) return Promise.reject(new TypeError("Failed to fetch"))
        return new Promise(resolve => window.__held.push(resolve)).then(() => original(url, options))
      }
    JS
  end

  def release!
    page.execute_script("window.__held.splice(0).forEach(r => r())")
  end

  def fail_submits!
    page.execute_script("window.__heldSubmits.splice(0).forEach(r => r())")
  end

  def redraw!
    page.execute_script("document.getElementById('controller_status').dataset.beforeRedraw = 'yes'")
    game.update!(flash_claim_id: nil)
    expect(page).to have_no_css("#controller_status[data-before-redraw]")
  end

  def sent = page.evaluate_script("window.__sent")
end

RSpec.shared_context "claim submit in portrait" do
  before do
    join
    resize(375, 667)
  end
end

RSpec.shared_context "claim submit with 8 players and 18 cards" do
  before do
    join(names: ["Bartholomew Ashworth", "Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan",
      "Jonas Oppenheimer", "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"], cards: 18)
  end
end

RSpec.shared_examples "keeps no page scroll during a claim" do |width, height|
  it "keeps no page scroll at #{width}x#{height} during a claim, Submit in the pill slot" do
    resize(width, height)
    claim!
    expect(page).to have_css("[data-card-id]", count: 18)
    expect(page).to have_css("[data-pill-slot] [data-card-selection-target='submit']", visible: true)
    expect(hint).to eq(["Tap 3 cards"])
    set_ids.each { |id| tap(id) }
    expect(hint).to eq(["Tap Submit"])
    expect(submit_button).not_to be_disabled
    expect(overflow).to eq([0, 0, 0])
  end
end
