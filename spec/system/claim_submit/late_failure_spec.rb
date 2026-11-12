require "rails_helper"

RSpec.describe "Submitting a claim", type: :system do
  include_context "claim submit"

  context "in portrait" do
    include_context "claim submit in portrait"

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
  end
end
