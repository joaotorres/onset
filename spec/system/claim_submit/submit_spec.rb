require "rails_helper"

RSpec.describe "Submitting a claim", type: :system do
  include_context "claim submit"

  context "in portrait" do
    include_context "claim submit in portrait"

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
  end
end
