require "rails_helper"

# Submit during the player's own claim (§8 Player screen 3, §11): enabled at
# exactly three picks, sent at once with the whole selection, the screen frozen
# until the resolving broadcast replaces it.
RSpec.describe "Submitting a claim", type: :system do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  let(:game) { Game.create! }
  let(:me) { game.players.order(:id).first }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def overflow
    page.evaluate_script(<<~JS)
      (() => {
        const d = document.documentElement, m = document.querySelector("main")
        return [d.scrollHeight - window.innerHeight, d.scrollWidth - window.innerWidth, m.scrollHeight - m.clientHeight]
      })()
    JS
  end

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

  context "in portrait" do
    before do
      join
      resize(375, 667)
    end

    it "enables Submit at exactly three picks and follows the picks in the hint" do
      claim!
      a, b, c = set_ids
      expect(submit_button).to be_disabled
      expect(submit_button.text).to eq("Submit")
      expect(hint).to eq(["Tap 3 cards"])

      tap(a)
      tap(b)
      expect(submit_button).to be_disabled
      expect(hint).to eq(["Tap 3 cards"])

      tap(c)
      expect(submit_button).not_to be_disabled
      expect(hint).to eq(["Tap Submit"])

      tap(c)
      expect(submit_button).to be_disabled
      expect(hint).to eq(["Tap 3 cards"])
    end

    it "enables Submit while the third pick is still on its way" do
      claim!
      hold_requests!
      set_ids.each { |id| tap(id) }
      expect(submit_button).not_to be_disabled
      expect(sent.size).to eq(1)
    end

    it "sends the three picks at once, freezes the screen and shows the found Set" do
      claim = claim!
      ids = set_ids
      hold_requests!
      ids.each { |id| tap(id) }
      submit_button.click

      expect(page).to have_css("[data-card-selection-target='submit'][aria-label='Submitted, waiting for the result']", text: "Submitted")
      submits = sent.select { |r| r["url"].end_with?("/submit") }
      expect(submits.size).to eq(1)
      expect(submits.first["method"]).to eq("POST")
      expect(JSON.parse(submits.first["body"])["card_ids"]).to eq(ids)
      expect(hint).to eq(["Judging…"])
      expect(submit_button).to be_disabled
      expect(page).to have_css("[data-card-selection-target='count']", text: "3", visible: true)
      expect(page).to have_css("[data-slot-card-id]", count: 3)

      other = (game.board - ids).first
      tap(other)
      expect(find("[data-card-id='#{other}']")["aria-pressed"]).to eq("false")
      tap(ids.first)
      expect(find("[data-card-id='#{ids.first}']")["aria-pressed"]).to eq("true")
      submit_button.click
      expect(sent.count { |r| r["url"].end_with?("/submit") }).to eq(1)

      release!
      expect(page).to have_css("[data-found-banner]")
      expect(page).to have_no_css("[data-controller='card-selection']")
      expect(page).to have_button("SET!")
      expect(claim.reload).to be_correct
    end

    it "shows the locked-out state after a wrong submit" do
      claim = claim!
      non_set_ids.each { |id| tap(id) }
      submit_button.click
      expect(page).to have_content("Wrong! −1")
      expect(page).to have_css("button[aria-label='SET! locked']")
      expect(claim.reload).to be_wrong
    end

    it "gives the screen back at 3/3 when the submit never reaches the server" do
      claim = claim!
      ids = set_ids
      hold_requests!(fail_submits: true)
      ids.each { |id| tap(id) }
      submit_button.click

      expect(page).to have_css("[data-card-selection-target='submit']:not([disabled])", text: "Submit", visible: true)
      expect(hint).to eq(["Tap Submit"])
      tap(ids.first)
      expect(find("[data-card-id='#{ids.first}']")["aria-pressed"]).to eq("false")
      expect(claim.reload).to be_pending
    end

    it "gives the redrawn screen back at 3/3 when the submit fails after a redraw" do
      claim = claim!
      ids = set_ids
      hold_requests!(fail_submits: :held)
      ids.each { |id| tap(id) }
      submit_button.click
      expect(hint).to eq(["Judging…"])

      redraw!
      expect(hint).to eq(["Judging…"])
      expect(submit_button).to be_disabled
      expect(find("[data-card-id='#{ids.first}']")).to be_disabled

      fail_submits!
      expect(page).to have_css("[data-card-selection-target='submit']:not([disabled])", text: "Submit", visible: true)
      expect(hint).to eq(["Tap Submit"])
      expect(page).to have_css("[data-card-selection-target='count']", text: "3", visible: true)
      expect(find("[data-card-id='#{ids.first}']")).not_to be_disabled
      tap(ids.first)
      expect(find("[data-card-id='#{ids.first}']")["aria-pressed"]).to eq("false")
      expect(claim.reload).to be_pending
    end

    it "leaves a new claim's screen alone when the old claim's submit fails late" do
      claim = claim!
      ids = set_ids
      hold_requests!(fail_submits: :held)
      ids.each { |id| tap(id) }
      submit_button.click
      expect(hint).to eq(["Judging…"])

      page.execute_script(<<~JS)
        window.__errors = []
        window.addEventListener("error", e => window.__errors.push(String(e.message)))
        window.addEventListener("unhandledrejection", e => window.__errors.push(String(e.reason)))
      JS
      game.with_lock { claim.expire! }
      expect(page).to have_no_css("[data-controller='card-selection']")
      me.update!(locked_until: nil)
      game.reload.try_claim!(me)
      expect(page).to have_css("[data-controller='card-selection']")
      tap(ids.first)
      expect(page).to have_css("[data-card-selection-target='count']", text: "1", visible: true)

      fail_submits!
      expect(page.evaluate_script("window.__heldSubmits.length")).to eq(0)
      expect(page).to have_css("[data-card-selection-target='count']", text: "1", visible: true)
      expect(hint).to eq(["Tap 3 cards"])
      expect(submit_button).to be_disabled
      expect(find("[data-card-id='#{ids.first}']")["aria-pressed"]).to eq("true")
      expect(page.evaluate_script("window.__errors")).to eq([])
    end

    it "keeps the tray and Submit at 176px so the board does not move" do
      visit game_controller_path(game.code)
      expect(page).to have_button("SET!")
      board = rect("[data-board]")
      claim!
      expect(rect("[data-board]")).to eq(board)
      tray = rect("[data-tray]")
      expect(tray["height"]).to eq(128)
      pill = rect("[data-pill-slot]")
      expect(pill["height"]).to eq(44)
      expect(pill["top"] + pill["height"] - tray["top"]).to eq(176)
      slot = rect("[data-card-selection-target='slot']")
      expect([slot["width"], slot["height"].round]).to eq([72, 101])
    end
  end

  context "with 8 players and 18 cards" do
    before do
      join(names: ["Bartholomew Ashworth", "Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan",
        "Jonas Oppenheimer", "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"], cards: 18)
    end

    [[375, 667], [667, 375], [1024, 640]].each do |width, height|
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
  end
end
