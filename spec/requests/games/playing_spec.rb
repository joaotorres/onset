require "rails_helper"

RSpec.describe "Games" do
  describe "GET /games/:code/controller while playing" do
    include_context "games while playing"

    it "lists every player by score, ties in join order" do
      alice.update!(score: 1)
      bob.update!(score: 3)
      cleo.update!(score: 1)
      names = entries(status).map { |li| li.at_css("[data-name]").text.strip }
      expect(names).to eq(%w[Bob Alice Cleo])
    end

    it "turns the claiming player's entry solid yellow" do
      game.try_claim!(bob)
      s = status
      expect(entry(s, "Bob")["class"]).to include("bg-yellow-400", "text-gray-950")
      expect(entry(s, "Cleo")["class"]).not_to include("bg-yellow-400")
    end

    it "tags a locked-out player's entry Locked" do
      bob.update!(locked_until: 5.seconds.from_now)
      s = status
      expect(entry(s, "Bob").text).to include("Locked")
      expect(entry(s, "Bob").at_css("[data-entry-content]")["class"]).to include("opacity-45")
      expect(entry(s, "Cleo").text).not_to include("Locked")
    end

    it "tints the player's own entry" do
      s = status
      expect(entry(s, "Alice")["class"]).to include("bg-gray-800", "border-gray-500")
      expect(entry(s, "Bob")["class"]).not_to include("bg-gray-800")
    end

    it "shows the cards left in the deck" do
      expect(status.text).to include("#{game.deck.size} cards left in the deck")
    end

    it "shows an orange Deck is empty pill once the deck runs out" do
      game.update!(deck: [])
      pill = status.css("span").find { |n| n.text.strip == "Deck is empty" }
      expect(pill["class"]).to include("bg-orange-700")
    end

    it "outlines the cards dealt by the last replace" do
      game.update!(last_dealt: game.board.first(3))
      s = status
      game.board.each do |id|
        card = s.at_css("[data-card-id='#{id}']")
        expect(card["class"].include?("animate-arrive")).to eq(game.board.first(3).include?(id))
      end
    end

    it "outlines dealt cards on a read-only board too" do
      game.update!(last_dealt: [game.board.first])
      game.try_claim!(bob)
      expect(status.at_css("[data-card-id='#{game.board.first}']")["class"]).to include("animate-arrive")
    end

    it "shows no header during play" do
      expect(status.at_css("header")).to be_nil
    end

    it "keeps the header while waiting" do
      game.update!(status: :waiting)
      expect(status.at_css("header")).to be_present
    end

    it "fills the idle No Set pill purple-700 with white text" do
      no_set = buttons(status, "No Set").first
      expect(no_set["class"]).to include("bg-purple-700", "text-white")
      expect(no_set["disabled"]).to be_nil
    end

    it "keeps No Set enabled while locked out" do
      alice.update!(locked_until: 5.seconds.from_now)
      no_set = buttons(status, "No Set")
      expect(no_set).not_to be_empty
      expect(no_set.map { |b| b["disabled"] }).to all(be_nil)
    end

    it "keeps the End game vote enabled while locked out with the deck empty" do
      game.update!(deck: [])
      alice.update!(locked_until: 5.seconds.from_now)
      end_game = buttons(status, "End game")
      expect(end_game).not_to be_empty
      expect(end_game.map { |b| b["disabled"] }).to all(be_nil)
    end

    it "offers no No Set during the player's own claim" do
      game.try_claim!(alice)
      s = status
      expect(s.text).to include("Your SET!")
      expect(buttons(s, "No Set")).to be_empty
    end

    it "keeps the 64px status slot, empty while idle" do
      slot = status.at_css("[data-status-slot]")
      expect(slot["class"]).to include("h-16")
      expect(slot.text.strip).to be_empty
    end

    it "fills the status slot with the caller's name while someone else claims" do
      game.try_claim!(bob)
      slot = status.at_css("[data-status-slot]")
      expect(slot.text.squish).to include("Bob is calling SET!")
      expect(slot.at_css("[class*='border-yellow-400']")).to be_present
    end

    it "fills the status slot with the No Set panel and n/m agreed" do
      game.call_no_set!(bob)
      slot = status.at_css("[data-status-slot]")
      expect(slot.text.squish).to include("No Set called by Bob", "1/3 agreed")
    end

    it "fills the status slot red and shaking when locked out after a wrong claim" do
      claim = game.try_claim!(alice)
      claim.update!(result: :wrong, resolved_at: Time.current)
      game.release_claim!
      alice.update!(locked_until: 5.seconds.from_now)
      panel = status.at_css("[data-status-slot] > *")
      expect(panel.text.strip).to eq("Wrong! −1")
      expect(panel["class"]).to include("bg-red-950", "border-red-600", "animate-shake")
    end

    it "counts SET! down from the claim time while locked out" do
      locked_until = Game::CLAIM_TIMEOUT.seconds.from_now.change(usec: 0)
      alice.update!(locked_until: locked_until)
      slot = status.at_css("[data-set-slot]")
      expect(slot["data-countdown-duration-value"]).to eq(Game::CLAIM_TIMEOUT.to_s)
      expect(slot["data-countdown-started-at-value"]).to eq((locked_until - Game::CLAIM_TIMEOUT.seconds).iso8601)
      expect(slot.at_css("[data-countdown-target=display]").text.strip).to eq(Game::CLAIM_TIMEOUT.to_s)
    end

    it "shows the found-set banner with the finder and +1" do
      claim = game.claims.create!(player: bob, result: :correct, card_ids: game.board.first(3), started_at: Time.current, resolved_at: Time.current)
      game.update!(flash_claim_id: claim.id)
      banner = status.at_css("[data-found-banner]")
      expect(banner.text.squish).to include("Bob found a Set", "+1")
      expect(banner["class"]).to include("found-set-flash", "pointer-events-none", "bg-green-950", "border-green-500")
    end

    it "shows no banner for another player's wrong claim" do
      claim = game.claims.create!(player: bob, result: :wrong, card_ids: game.board.first(3), started_at: Time.current, resolved_at: Time.current)
      game.update!(flash_claim_id: claim.id)
      expect(status.at_css("[data-found-banner]")).to be_nil
    end
  end
end
