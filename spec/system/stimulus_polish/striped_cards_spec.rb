require "rails_helper"

RSpec.describe "Stimulus polish", type: :system do
  include_context "stimulus polish"

  describe "striped cards after a tap" do
    # Returns the problems found: duplicate ids in the document, and url(#id)
    # fills in any SVG that do not resolve to an element inside that SVG.
    def svg_id_problems = page.evaluate_script("(() => { #{svg_id_problems_js} })()")

    def svg_id_problems_js = <<~JS
      const problems = []
      const seen = {}
      document.querySelectorAll("[id]").forEach(el => {
        if (seen[el.id]) problems.push("duplicate id " + el.id)
        seen[el.id] = true
      })
      document.querySelectorAll("svg").forEach(svg => {
        svg.querySelectorAll("[fill^='url(']").forEach(el => {
          const id = el.getAttribute("fill").slice(5, -1) // url(#id)
          if (!svg.querySelector("[id='" + id + "']")) problems.push("fill " + id + " not inside its own svg")
        })
      })
      return problems
    JS

    # Ids 1, 4 and 7 are blue striped, 10 orange striped.
    def setup_striped_claim(width:, height:)
      page.driver.browser.manage.window.resize_to(width, height)
      player = setup_claim_state
      player.game.update!(board: (0..11).to_a)
      visit game_controller_path(player.game.code)
    end

    def striped_cards_resolve!
      expect(page).to have_css("[data-card-id='4'] svg")
      expect(page.evaluate_script("document.querySelectorAll(\"[data-card-selection-target='card'] svg [fill^='url(']\").length")).to be > 0
      expect(svg_id_problems).to eq([])
    end

    it "keeps ids unique and fills inside their own SVG in a landscape window" do
      setup_striped_claim(width: 1280, height: 800)

      find("[data-card-id='4']").click
      expect(find("[data-card-id='4']")[:class]).to include("ring-4")
      striped_cards_resolve!
    end

    it "points the tray copy at a pattern inside the copy in a portrait window" do
      setup_striped_claim(width: 420, height: 900)

      find("[data-card-id='4']").click
      expect(page).to have_css("[data-slot-card-id='4'] svg pattern", visible: :all)
      striped_cards_resolve!
    end

    it "leaves no duplicate ids after deselecting and re-selecting" do
      setup_striped_claim(width: 1280, height: 800)

      card = find("[data-card-id='7']")
      card.click
      card.click
      card.click
      expect(page).to have_css("[data-slot-card-id='7'] svg", visible: :all)
      striped_cards_resolve!
    end
  end
end
