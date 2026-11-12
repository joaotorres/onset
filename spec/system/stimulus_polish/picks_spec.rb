require "rails_helper"

RSpec.describe "Stimulus polish", type: :system do
  include_context "stimulus polish"

  it "highlights a card on tap and removes highlight on re-tap (deselect)" do
    setup_claim_state

    cards = all("[data-card-id]")
    first_card = cards.first

    first_card.click
    expect(first_card[:class]).to include("ring-4")

    first_card.click
    expect(first_card[:class]).not_to include("ring-4")
  end

  it "selecting two cards and deselecting one leaves only one highlighted" do
    setup_claim_state

    cards = all("[data-card-id]")
    cards[0].click
    cards[1].click
    expect(cards[0][:class]).to include("ring-4")
    expect(cards[1][:class]).to include("ring-4")

    cards[0].click
    expect(cards[0][:class]).not_to include("ring-4")
    expect(cards[1][:class]).to include("ring-4")
  end

  it "shows the picks again after a redraw mid-claim in a portrait window" do
    page.driver.browser.manage.window.resize_to(420, 900)
    player = setup_claim_state
    game = player.game
    claim = game.claims.find_by!(player: player, result: :pending)
    ids = game.board.first(2)

    ids.each { |id| find("[data-card-id='#{id}']").click }
    deadline = Time.current + Capybara.default_max_wait_time
    sleep 0.05 until claim.reload.card_ids == ids || Time.current > deadline
    expect(claim.card_ids).to eq(ids)

    page.execute_script("document.getElementById('controller_status').dataset.beforeRedraw = 'yes'")
    game.update!(flash_claim_id: nil)
    expect(page).to have_no_css("#controller_status[data-before-redraw]")

    ids.each { |id| expect(page).to have_css("[data-card-id='#{id}'][aria-pressed='true'].ring-4") }
    expect(page).to have_css("[data-card-selection-target='count']", text: "2")
    ids.each { |id| expect(page).to have_css("[data-slot-card-id='#{id}'] svg") }
  end

  it "countdown ring is present in the DOM with correct data attributes" do
    setup_claim_state

    countdown = find("[data-controller='countdown']")
    expect(countdown["data-countdown-duration-value"]).to eq(Game::CLAIM_TIMEOUT.to_s)
    expect(countdown["data-countdown-started-at-value"]).to be_present
    expect(page).to have_css("[data-countdown-target='ring']")
    expect(page).to have_css("[data-countdown-target='display']")
  end
end
