require "rails_helper"

RSpec.describe "Games" do
  describe "GET /games/:code/controller while waiting" do
    let(:game) { Game.create! }

    def sign_in_player(name: "Alice", color: "#E74C3C")
      post game_players_path(game.code), params: {player: {name: name, color: color}}
      game.players.find_by!(name: name)
    end

    def status
      get game_controller_path(game.code)
      Nokogiri::HTML(response.body).at_css("#controller_status")
    end

    let(:join_url) { "http://www.example.com/games/#{game.code}/players/join" }

    context "with two players" do
      let!(:alice) { sign_in_player }
      let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71") }

      it "shows the room code and the host line" do
        invite = status.at_css("[data-controller='invite']")
        expect(invite.text).to include(game.code)
        expect(invite.text.squish).to include("or open www.example.com and enter the code")
      end

      it "gives the invite controller the absolute join URL and the code" do
        invite = status.at_css("[data-controller='invite']")
        expect(invite["data-invite-url-value"]).to eq(join_url)
        expect(invite["data-invite-code-value"]).to eq(game.code)
        link = invite.at_css("[data-invite-target='link']")
        expect(link["data-action"]).to include("click->invite#share")
        expect(link.text).to include("Copy link")
      end

      it "puts the join QR inside a dialog in #controller_status" do
        dialog = status.at_css("dialog[data-invite-target='sheet']")
        expect(dialog.at_css("svg")).to be_present
        expect(dialog.text).to include(game.code)
        expect(dialog.at_css("[data-action*='click->invite#close']").text).to include("Done")
        expect(status.at_css("[data-action*='click->invite#open']").text).to include("Show QR")
      end

      it "links to the big screen in a new tab" do
        link = status.css("a").find { |a| a.text.include?("Show on a big screen") }
        expect(link["href"]).to eq(game_path(game.code))
        expect(link["target"]).to eq("_blank")
      end

      it "shows the invite to a player who is not the creating browser" do
        cookies.delete(:host_game)
        expect(status.at_css("[data-controller='invite']")).to be_present
      end

      it "shows I'm ready on green-700 and the roster in two columns" do
        s = status
        button = s.at_css("form[action='#{ready_game_path(game.code)}'] button")
        expect(button.text).to include("I'm ready")
        expect(button[:class]).to include("bg-green-700")
        expect(s.at_css("[data-roster]")[:class]).to include("grid-cols-2")
        expect(s.css("[data-roster] li").size).to eq(2)
      end

      it "shows the voted line outlined on a green-700 tint" do
        post ready_game_path(game.code)
        line = status.css("p").find { |p| p.text.include?("Ready ✓ · waiting for 1 more") }
        expect(line[:class]).to include("border-green-700", "bg-green-700/12", "text-green-300")
      end

      it "drops the invite once playing" do
        game.start!
        expect(status.at_css("[data-controller='invite']")).to be_nil
        expect(status.at_css("dialog")).to be_nil
      end

      it "drops the invite once ended" do
        game.update!(status: :ended, board: [], deck: [], discard: [])
        expect(status.at_css("[data-controller='invite']")).to be_nil
      end
    end

    context "alone in the room" do
      let!(:alice) { sign_in_player }

      it "shows the waiting line and no I'm ready button" do
        s = status
        expect(s.text).to include("Waiting for more players to join…")
        expect(s.at_css("form[action='#{ready_game_path(game.code)}']")).to be_nil
        expect(s.at_css("[data-controller='invite']")).to be_present
      end
    end
  end
end
