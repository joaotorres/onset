require "rails_helper"

RSpec.describe "Tapping a card calls SET!", type: :system do
  include_context "tap card claim"

  it "takes the claim and opens it with the tapped card selected" do
    card(4).click

    expect(page).to have_content("Your SET!")
    expect(card(4)[:class]).to include("ring-4")
    expect(card(4)["aria-pressed"]).to eq("true")
    expect(count_text).to all(eq("1"))
    expect(game.claims.where(player: alice, result: :pending).count).to eq(1)
    expect_server_picks([4])
  end

  it "keeps three picks pending on the server, the board undimmed, until the time runs out" do
    card(0).click
    expect(page).to have_content("Your SET!")
    card(1).click
    card(2).click

    expect_picked(0, 1, 2)
    expect(count_text).to all(eq("3"))
    expect_server_picks([0, 1, 2])
    expect(alice_claim).to be_pending
    expect(page).to have_no_css("[data-board] .opacity-50")
    expect(page).to have_content("Your SET!")

    card(1).click
    expect(card(1)["aria-pressed"]).to eq("false")
    expect_server_picks([0, 2])
  end

  it "sends the picks without form.requestSubmit" do
    page.execute_script("delete HTMLFormElement.prototype.requestSubmit")
    card(0).click
    expect(page).to have_content("Your SET!")
    page.execute_script("delete HTMLFormElement.prototype.requestSubmit")
    card(1).click
    card(2).click

    expect_server_picks([0, 1, 2])
  end

  it "deselects the pre-selected card on a second tap" do
    card(4).click
    expect(page).to have_content("Your SET!")
    expect(card(4)["aria-pressed"]).to eq("true")

    card(4).click
    expect(card(4)["aria-pressed"]).to eq("false")
    expect(count_text).to all(eq("0"))
  end
end
