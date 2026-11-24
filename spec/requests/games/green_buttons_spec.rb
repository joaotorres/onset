require "rails_helper"

RSpec.describe "Games" do
  describe "GET /games/:code green buttons" do
    let(:game) { Game.create! }

    before do
      create_player(game, name: "Alice")
      create_player(game, name: "Bob")
    end

    def page = Nokogiri::HTML(response.body)

    def expect_green_700(button)
      classes = button[:class].split
      expect(classes).to include("bg-green-700", "hover:bg-green-800")
      expect(classes).not_to include("bg-green-600", "hover:bg-green-500")
    end

    it "uses green-700 for Start game while waiting with 2 players" do
      get game_path(game.code)
      expect_green_700(page.at_css("form[action='#{start_game_path(game.code)}'] button"))
    end

    it "keeps the disabled Start game gray with fewer than 2 players" do
      game.players.last.destroy!
      get game_path(game.code)
      expect(page.at_css("#start_button button[disabled]")[:class]).to include("bg-gray-800")
    end

    it "uses green-700 for Play again at game over" do
      game.update!(status: :ended, board: [], deck: [], discard: [])
      get game_path(game.code)
      expect_green_700(page.at_css("form[action='#{restart_game_path(game.code)}'] button"))
    end

    it "puts bg-green-600 on no button in any view" do
      offenders = Dir[Rails.root.join("app/views/**/*.erb")].select { |path| File.read(path).include?("bg-green-600") }
      expect(offenders).to be_empty
    end
  end
end
