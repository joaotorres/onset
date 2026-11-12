require "rails_helper"

RSpec.describe "Realtime sync", type: :system do
  include_context "realtime sync"

  it "claim on one phone appears on other phones and board instantly" do
    on("phone1") do
      click_button "SET!"
      expect(page).to have_content("Tap 3 cards")
    end

    on("phone2") do
      expect(page).to have_content("is calling SET!")
      expect(page).to have_content("Alice")
    end

    expect(page).to have_content("Alice is calling SET!")
    expect(page).to have_css("#scoreboard li.bg-yellow-400", text: "Alice")
  end
end
