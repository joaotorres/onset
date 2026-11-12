require "rails_helper"

RSpec.describe "Players" do
  include_context "players"

  describe "GET /games/:code/players/join" do
    it "returns 200 and shows the join form" do
      get join_game_players_path(game.code)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Joining room")
    end

    it "marks a taken color with the initial of the player who took it" do
      game.players.create!(name: "marta", color: "#1ABC9C")
      get join_game_players_path(game.code)
      expect(response.body).to include('title="Taken by marta"')
      initial = Nokogiri::HTML(response.body).at_css("label[title='Taken by marta'] span")
      expect(initial.text).to eq("M")
      expect(initial["class"]).to include("text-gray-300", "font-display")
    end

    it "selects the first preset color on an empty game" do
      get join_game_players_path(game.code)
      expect(checked_colors).to eq([presets[0]])
    end

    it "selects the first free color when the first two are taken" do
      game.players.create!(name: "a", color: presets[0])
      game.players.create!(name: "b", color: presets[1])
      get join_game_players_path(game.code)
      expect(checked_colors).to eq([presets[2]])
      [presets[0], presets[1]].each do |hex|
        expect(radio_for(hex)["checked"]).to be_nil
        expect(radio_for(hex)["disabled"]).to be_present
      end
    end

    it "says the room is full and disables Join when every color is taken" do
      presets.each_with_index { |hex, i| game.players.create!(name: "p#{i}", color: hex) }
      get join_game_players_path(game.code)
      expect(checked_colors).to be_empty
      doc = Nokogiri::HTML(response.body)
      expect(doc.at_css(".border-red-700")&.text).to include("This room is full")
      submit = doc.at_css("input[type=submit][value=Join]")
      expect(submit["disabled"]).to be_present
    end

    it "keeps Join enabled while a color is free" do
      get join_game_players_path(game.code)
      submit = Nokogiri::HTML(response.body).at_css("input[type=submit][value=Join]")
      expect(submit["disabled"]).to be_nil
      expect(response.body).not_to include("This room is full")
    end

    describe "the big screen link" do
      def big_screen_link = Nokogiri::HTML(response.body).at_css("a:contains('Use this screen as the big screen instead')")

      it "shows to the browser that created the room, linking to its big screen in the same tab" do
        post games_path
        code = Game.last.code
        get join_game_players_path(code)
        expect(big_screen_link["href"]).to eq(game_path(code))
        expect(big_screen_link["target"]).to be_nil
      end

      it "is absent without the host cookie" do
        get join_game_players_path(game.code)
        expect(big_screen_link).to be_nil
      end

      it "is absent with another room's host cookie" do
        post games_path
        get join_game_players_path(game.code)
        expect(big_screen_link).to be_nil
      end
    end
  end
end
