require "rails_helper"

RSpec.describe "Games" do
  describe "GET /games/:code/controller once ended" do
    let(:game) { Game.create! }

    def sign_in_player(name: "Alice", color: "#E74C3C")
      post game_players_path(game.code), params: {player: {name: name, color: color}}
      game.players.find_by!(name: name)
    end

    def end_with(scores)
      game.players.order(:id).zip(scores).each { |p, s| p.update!(score: s) }
      game.update!(status: :ended, board: [], deck: [], discard: [])
      get game_controller_path(game.code)
      Nokogiri::HTML(response.body).at_css("#controller_status")
    end

    let!(:alice) { sign_in_player }
    let!(:bob) { create_player(game, name: "Bob") }
    let!(:cleo) { create_player(game, name: "Cleo") }

    def rows(status)
      status.css("[data-standings] li")
    end

    it "lists every player once, by score with ties in join order, sharing ranks" do
      status = end_with([3, 5, 5])
      expect(rows(status).size).to eq(3)
      expect(rows(status).map { |r| r.at_css("[data-name]").text.strip }).to eq(%w[Bob Cleo Alice])
      expect(rows(status).map { |r| r.at_css("[data-row-rank]").text.strip }).to eq(%w[1 1 3])
      expect(rows(status).map { |r| r.at_css("[data-row-score]").text.strip }).to eq(%w[5 5 3])
      expect(status.text).to include("of 3 players")
    end

    it "marks only the viewer's row with you and the surface tint" do
      status = end_with([3, 5, 1])
      own = rows(status).select { |r| r.text.include?("you") }
      expect(own.size).to eq(1)
      expect(own.first.at_css("[data-name]").text.strip).to eq("Alice")
      expect(own.first[:class]).to include("bg-gray-800", "border-gray-600")
      rows(status).reject { |r| own.include?(r) }.each { |r| expect(r[:class]).not_to include("bg-gray-800") }
    end

    it "puts no star, Locked tag or ready mark in the rows" do
      alice.update!(locked_until: 1.minute.from_now)
      game.update!(start_voters: [bob.id])
      status = end_with([3, 5, 1])
      text = status.at_css("[data-standings]").text
      expect(text).not_to include("★")
      expect(text).not_to include("Locked")
      expect(text).not_to include("✓")
    end

    it "orders game over, rank, points, winner line, standings, then Play again" do
      status = end_with([3, 5, 1])
      html = status.to_html
      positions = ["Game over", "data-rank", "of 3 players", "data-winner-line", "data-standings", "Play again"].map { |s| html.index(s) }
      expect(positions).to all(be_present)
      expect(positions).to eq(positions.sort)
    end

    it "names another sole winner" do
      status = end_with([3, 9, 1])
      expect(status.at_css("[data-winner-line]").text.squish).to eq("★ Bob wins with 9")
      expect(status.at_css("[data-rank]").text.strip).to eq("2nd")
    end

    it "says You win when the viewer is the sole winner" do
      status = end_with([9, 3, 1])
      expect(status.at_css("[data-winner-line]").text.squish).to eq("★ You win with 9")
    end

    it "says Tied for first on a tie, the tied viewer ranked 1st" do
      status = end_with([9, 9, 1])
      expect(status.at_css("[data-winner-line]").text.squish).to eq("★ Tied for first at 9")
      expect(status.at_css("[data-rank]").text.strip).to eq("1st")
    end

    it "uses green-700 for Play again" do
      status = end_with([3, 5, 1])
      expect(status.at_css("form[action='#{ready_game_path(game.code)}'] button")[:class]).to include("bg-green-700")
    end

    it "shows the voted line outlined in green-700 with green-300 text" do
      game.update!(start_voters: [alice.id])
      status = end_with([3, 5, 1])
      line = status.css("p").find { |p| p.text.include?("Ready ✓ · waiting for") }
      expect(line[:class]).to include("border-green-700", "bg-green-700/12", "text-green-300")
    end
  end
end
