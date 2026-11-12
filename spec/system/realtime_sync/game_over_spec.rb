require "rails_helper"

RSpec.describe "Realtime sync", type: :system do
  include_context "realtime sync"

  # Regression: phone actions used to redirect, and the page reload dropped the
  # phone's stream subscription for ~500 ms. A second vote landing in that window
  # left the first voter stuck on "Voted to end".
  it "both phones see game over when the end game votes land back to back" do
    Game.find_by!(code: @code).update!(deck: [])
    on("phone1") { expect(page).to have_button("End game") }
    on("phone2") { expect(page).to have_button("End game") }

    on("phone1") do
      click_button "End game"
      expect(page).to have_content("Voted to end")
    end
    on("phone2") { click_button "End game" }

    on("phone1") { expect(page).to have_content(/game over/i) }
    on("phone2") { expect(page).to have_content(/game over/i) }
    expect(page).to have_button("Play again")
  end
end
