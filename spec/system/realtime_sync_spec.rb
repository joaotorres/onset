require "rails_helper"

RSpec.describe "Realtime sync", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  def join(session, name, swatch)
    Capybara.using_session(session) do
      visit join_game_players_path(@code)
      fill_in "player[name]", with: name
      all("label.cursor-pointer")[swatch].click
      click_button "Join"
      expect(page).to have_content("Waiting for players")
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
    end
  end

  def on(session, &) = Capybara.using_session(session, &)

  before do
    visit root_path
    click_button "Start a game"
    @code = find("p.text-5xl").text
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)

    join("phone1", "Alice", 0)
    join("phone2", "Bob", 1)

    # Both phones vote to start; the board follows via broadcast.
    on("phone1") { click_button "Start Game" }
    on("phone2") { click_button "Start Game" }
    on("phone1") { expect(page).to have_button("SET!") }
    on("phone2") { expect(page).to have_button("SET!") }
  end

  it "claim on one phone appears on other phones and board instantly" do
    on("phone1") do
      click_button "SET!"
      expect(page).to have_content("Pick 3 cards")
    end

    on("phone2") { expect(page).to have_content("Alice is calling SET!") }

    expect(page).to have_content("Alice is calling SET!")
    expect(page).to have_css("#scoreboard .text-yellow-400", text: "Alice")
  end

  # Regression: phone actions used to redirect, and the page reload dropped the
  # phone's stream subscription for ~500 ms. A second vote landing in that window
  # left the first voter stuck on "Voted to end".
  it "both phones see game over when the end game votes land back to back" do
    Game.find_by!(code: @code).update!(deck: [])
    on("phone1") { expect(page).to have_button("End Game") }
    on("phone2") { expect(page).to have_button("End Game") }

    on("phone1") do
      click_button "End Game"
      expect(page).to have_content("Voted to end")
    end
    on("phone2") { click_button "End Game" }

    on("phone1") { expect(page).to have_content("Game Over") }
    on("phone2") { expect(page).to have_content("Game Over") }
    expect(page).to have_button("Play Again")
  end
end
