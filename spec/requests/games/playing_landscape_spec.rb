require "rails_helper"

RSpec.describe "Games" do
  describe "GET /games/:code/controller while playing" do
    include_context "games while playing"

    context "the landscape scores column" do
      it "lists every player in order, each with dot, name and score" do
        alice.update!(score: 2)
        bob.update!(score: 3)
        s = status
        board = s.at_css("[data-scoreboard]")
        expect(board["class"]).to include("landscape:max-lg:flex-col", "landscape:max-lg:order-last")
        expect(entries(s).map { |li| li.at_css("[data-name]").text.strip }).to eq(%w[Bob Alice Cleo])
        expect(entries(s).map { |li| li.at_css("[data-score]").text.strip }).to eq(%w[3 2 0])
      end

      it "puts the Locked tag inline before the score" do
        bob.update!(locked_until: 5.seconds.from_now)
        li = entry(status, "Bob")
        tag = li.at_css("[data-locked-tag]")
        expect(tag.text.strip).to eq("Locked")
        expect(tag["class"]).to include("portrait:max-lg:absolute", "landscape:max-lg:static")
        kids = li.element_children
        expect(kids.index(tag)).to be < kids.index(li.at_css("[data-score]"))
        expect(li.at_css("[data-score]")["class"]).to include("text-muted", "light:text-gray-500")
        expect(li.at_css("[data-score]")["class"]).not_to include("opacity-")
        expect(tag["class"]).not_to include("opacity-45")
      end

      it "drops the info column during play" do
        expect(status.css("p").map { |n| n.text.strip }).not_to include("Score")
      end
    end

    context "the landscape action column" do
      it "keeps one status slot, sized 144x104 in landscape" do
        slot = status.css("[data-status-slot]")
        expect(slot.size).to eq(1)
        expect(slot.first["class"]).to include("h-16", "landscape:max-lg:h-[104px]", "landscape:max-lg:w-full")
      end

      it "puts the status slot, SET! and the pill in the 9rem action column" do
        s = status
        column = s.at_css("[data-action-column]")
        expect(column["class"]).to include("w-36", "portrait:max-lg:contents")
        expect(column.at_css("[data-status-slot]")).to be_present
        expect(column.at_css("[data-set-slot]")["class"]).to include("size-32")
        expect(column.at_css("[data-pill-slot]").text).to include("No Set")
      end

      it "replaces the status panel and SET! with one yellow block during my claim, Submit in the pill slot" do
        game.try_claim!(alice)
        s = status
        column = s.at_css("[data-action-column]")
        block = column.at_css("[data-claim-block]")
        expect(block["class"]).to include("portrait:max-lg:hidden", "bg-yellow-400")
        expect(block.text.squish).to include("Your SET!", "Tap 3 cards", "0/3")
        expect(column.at_css("[data-set-slot]")).to be_nil
        expect(buttons(s, "SET!")).to be_empty
        pill = column.at_css("[data-pill-slot]")
        expect(pill["class"]).not_to include("portrait:max-lg:hidden")
        submit = pill.at_css("button[data-card-selection-target='submit']")
        expect(submit.text.squish).to eq("Submit")
        expect(submit["disabled"]).to be_present
        expect(s.css("button[data-card-selection-target='card']").size).to eq(game.board.size)
      end

      it "shows the No Set panel with n/m agreed in the status slot" do
        game.call_no_set!(bob)
        slot = status.at_css("[data-action-column] [data-status-slot]")
        expect(slot.text.squish).to include("No Set called by Bob", "1/3 agreed")
      end
    end

    it "keeps the deck line with the board in landscape" do
      line = status.css("p").find { |n| n.text.include?("cards left in the deck") }
      expect(line["class"]).not_to include("landscape:max-lg:hidden")
    end

    it "fits the board to its width with no sideways scroll" do
      board = status.at_css("[data-board]")
      expect(board["class"]).to include("[container-type:size]")
      expect(board["class"]).not_to include("overflow-x-auto")
    end
  end
end
