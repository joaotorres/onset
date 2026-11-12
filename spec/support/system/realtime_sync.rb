# Shared by the spec files in spec/system/realtime_sync/.
RSpec.shared_context "realtime sync" do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  def join(session, name, swatch)
    Capybara.using_session(session) do
      visit join_game_players_path(@code)
      fill_in "player[name]", with: name
      all("label.cursor-pointer")[swatch].click
      click_button "Join"
      expect(page).to have_content("You're in")
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
    end
  end

  def on(session, &) = Capybara.using_session(session, &)

  before do
    visit root_path
    click_button "Start a game"
    click_link "Use this screen as the big screen instead"
    @code = find("[data-room-code]").text
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)

    join("phone1", "Alice", 0)
    join("phone2", "Bob", 1)

    # Both phones vote to start; the board follows via broadcast.
    on("phone1") { click_button "I'm ready" }
    on("phone2") { click_button "I'm ready" }
    on("phone1") { expect(page).to have_button("SET!") }
    on("phone2") { expect(page).to have_button("SET!") }
  end
end
