require "rails_helper"

RSpec.describe "Submitting a claim", type: :system do
  include_context "claim submit"

  context "in portrait" do
    include_context "claim submit in portrait"

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
  end
end
