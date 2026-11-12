require "rails_helper"

RSpec.describe "Submitting a claim", type: :system do
  include_context "claim submit"

  context "in portrait" do
    include_context "claim submit in portrait"

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
  end
end
