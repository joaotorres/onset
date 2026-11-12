require "rails_helper"

RSpec.describe "Player screen waiting invite", type: :system do
  include_context "waiting invite"

  describe "with a touch screen and Web Share" do
    before do
      visit root_path
      bridge = page.driver.browser
      bridge.execute_cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
      @share_stub = bridge.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
        window.__shared = null;
        navigator.share = (data) => { window.__shared = data; return Promise.resolve(); };
      JS
      join_as("Ada")
      add_players(1)
      expect(page).to have_css("[data-roster] li", count: 2)
    end

    after do
      bridge = page.driver.browser
      bridge.execute_cdp("Emulation.setTouchEmulationEnabled", enabled: false)
      bridge.execute_cdp("Page.removeScriptToEvaluateOnNewDocument", identifier: @share_stub["identifier"])
    end

    it "reads Share link and shares the join URL with the room title" do
      expect(page).to have_button("Share link")
      click_button "Share link"
      expect(page).to have_button("Share link")
      shared = page.evaluate_script("window.__shared")
      expect(shared["title"]).to eq("Room #{game.code}")
      expect_join_url(shared["url"])
    end
  end
end
