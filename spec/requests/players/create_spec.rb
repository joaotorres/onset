require "rails_helper"

RSpec.describe "Players" do
  include_context "players"

  describe "POST /games/:code/players" do
    let(:valid_params) { {player: {name: "Alice", color: "#E74C3C"}} }

    context "when rate limited" do
      # The test env uses a null cache store, so count in a real one.
      let(:store) { ActiveSupport::Cache::MemoryStore.new }

      before do
        allow(PlayersController.cache_store).to receive(:increment) { |*args, **opts| store.increment(*args, **opts) }
      end

      it "returns 429 after 20 requests a minute" do
        20.times { post game_players_path(game.code), params: {player: {name: "x", color: "#zzz"}} }
        expect(response).not_to have_http_status(:too_many_requests)

        expect { post game_players_path(game.code), params: valid_params }.not_to change(Player, :count)
        expect(response).to have_http_status(:too_many_requests)
        expect(response.body).to include("Try again in a minute.")
        expect(checked_colors).to eq([presets[0]])
      end
    end

    it "does not make the creator the host player" do
      post games_path
      created = Game.last
      post game_players_path(created.code), params: valid_params
      expect(created.players.count).to eq(1)
      expect(created.reload.host_player_id).to be_nil
    end

    it "creates a player and redirects to the controller view" do
      expect { post game_players_path(game.code), params: valid_params }
        .to change(Player, :count).by(1)
      expect(response).to redirect_to(game_controller_path(game.code))
    end

    it "sets the player token cookie" do
      post game_players_path(game.code), params: valid_params
      expect(cookies[:player_token]).to be_present
    end

    it "re-renders the form on invalid params" do
      post game_players_path(game.code), params: {player: {name: "", color: "#E74C3C"}}
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "keeps the posted free color on a name error" do
      post game_players_path(game.code), params: {player: {name: "", color: presets[3]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(checked_colors).to eq([presets[3]])
    end

    it "joins with the preselected color and a name" do
      get join_game_players_path(game.code)
      preselected = checked_colors.first
      post game_players_path(game.code), params: {player: {name: "Zed", color: preselected}}
      expect(response).to redirect_to(game_controller_path(game.code))
      expect(game.players.last.color).to eq(presets[0])
    end

    it "selects the next free color after a clash, wrapping past the last" do
      game.players.create!(name: "a", color: presets[0])
      game.players.create!(name: "h", color: presets[7])
      post game_players_path(game.code), params: {player: {name: "Bob", color: presets[7]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(checked_colors).to eq([presets[1]])
      expect(radio_for(presets[7])["checked"]).to be_nil
    end

    it "redirects with an alert when the game has already started" do
      game.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: [])
      post game_players_path(game.code), params: valid_params
      expect(response).to redirect_to(join_game_players_path(game.code))
    end

    it "refuses a color that is not a preset" do
      expect { post game_players_path(game.code), params: {player: {name: "Bob", color: "#FE6100"}} }
        .not_to change(Player, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("is not included in the list")
      expect(checked_colors).to eq([presets[0]])
    end

    it "refuses a ninth join whatever color it posts" do
      presets.each_with_index { |hex, i| game.players.create!(name: "p#{i}", color: hex) }
      [presets[0], "#FE6100"].each do |color|
        expect { post game_players_path(game.code), params: {player: {name: "Nine", color: color}} }
          .not_to change(Player, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("This room is full")
      end
    end

    it "answers a join that loses the race at the index with the color error" do
      game.players.create!(name: "a", color: presets[0])
      allow_any_instance_of(Player).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)
      post game_players_path(game.code), params: {player: {name: "Bob", color: presets[0]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("has already been taken in this game")
      expect(checked_colors).to eq([presets[1]])
    end

    it "answers a join that loses the race on the name with the name error and keeps a free color" do
      game.players.create!(name: "Alex", color: presets[0])
      allow_any_instance_of(Player).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)
      expect { post game_players_path(game.code), params: {player: {name: "alex", color: presets[1]}} }
        .not_to change(Player, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("has already been taken in this game")
      expect(checked_colors).to eq([presets[1]])
    end

    it "shows both errors when the race is lost on name and color" do
      game.players.create!(name: "Alex", color: presets[0])
      allow_any_instance_of(Player).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)
      post game_players_path(game.code), params: {player: {name: "alex", color: presets[0]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body.scan("has already been taken in this game").size).to eq(2)
      expect(checked_colors).to eq([presets[1]])
    end

    context "when the winner commits during the request" do
      def swatch_initial(hex) = radio_for(hex).ancestors("label").first.at_css("span").text

      def fill_room_but(hex)
        presets.reject { |c| c == hex }.each_with_index { |c, i| game.players.create!(name: "p#{i}", color: c) }
      end

      def win_then_raise(name:, color:)
        allow_any_instance_of(Player).to receive(:save) do
          game.players.create!(name: name, color: color)
          raise ActiveRecord::RecordNotUnique
        end
      end

      def win_then_save(name:, color:)
        allow_any_instance_of(Player).to receive(:save).and_wrap_original do |original, *args|
          game.players.create!(name: name, color: color)
          original.call(*args)
        end
      end

      it "selects the next free color when the race at the color index is lost" do
        game.players.create!(name: "a", color: presets[3])
        win_then_raise(name: "Wanda", color: presets[2])
        expect { post game_players_path(game.code), params: {player: {name: "Bob", color: presets[2]}} }
          .to change(Player, :count).by(1)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("has already been taken in this game")
        expect(game.players.where(name: "Bob")).to be_empty
        expect(checked_colors).to eq([presets[4]])
        expect(radio_for(presets[2])["disabled"]).to be_present
        expect(radio_for(presets[2])["checked"]).to be_nil
        expect(swatch_initial(presets[2])).to eq("W")
      end

      it "says the room is full when the lost race was for the last color" do
        fill_room_but(presets[5])
        win_then_raise(name: "Wanda", color: presets[5])
        post game_players_path(game.code), params: {player: {name: "Bob", color: presets[5]}}
        expect(response).to have_http_status(:unprocessable_content)
        expect(Nokogiri::HTML(response.body).at_css("[role=alert]").text).to include("This room is full")
        expect(checked_colors).to be_empty
        expect(Nokogiri::HTML(response.body).at_css("input[type=submit]")["disabled"]).to be_present
      end

      it "keeps a free color and draws the winner's taken when the race on the name is lost" do
        win_then_raise(name: "Alex", color: presets[0])
        post game_players_path(game.code), params: {player: {name: "alex", color: presets[1]}}
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Name has already been taken in this game")
        expect(checked_colors).to eq([presets[1]])
        expect(radio_for(presets[0])["disabled"]).to be_present
        expect(swatch_initial(presets[0])).to eq("A")
      end

      it "answers as a taken color when the validations see the winner" do
        win_then_save(name: "Wanda", color: presets[6])
        expect { post game_players_path(game.code), params: {player: {name: "Bob", color: presets[6]}} }
          .to change(Player, :count).by(1)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("has already been taken in this game")
        expect(checked_colors).to eq([presets[7]])
        expect(radio_for(presets[6])["disabled"]).to be_present
        expect(radio_for(presets[6])["checked"]).to be_nil
        expect(swatch_initial(presets[6])).to eq("W")
      end

      it "says the room is full when the validations see the winner on the last color" do
        fill_room_but(presets[0])
        win_then_save(name: "Wanda", color: presets[0])
        post game_players_path(game.code), params: {player: {name: "Bob", color: presets[0]}}
        expect(response).to have_http_status(:unprocessable_content)
        expect(Nokogiri::HTML(response.body).at_css("[role=alert]").text).to include("This room is full")
        expect(checked_colors).to be_empty
        expect(Nokogiri::HTML(response.body).at_css("input[type=submit]")["disabled"]).to be_present
      end
    end

    it "answers a plain taken name with the name error" do
      game.players.create!(name: "Alex", color: presets[0])
      post game_players_path(game.code), params: {player: {name: "ALEX", color: presets[1]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("has already been taken in this game")
    end

    it "rejects a duplicate color in the same game" do
      Player.create!(name: "Alice", color: "#E74C3C", game: game)
      post game_players_path(game.code), params: {player: {name: "Bob", color: "#E74C3C"}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("has already been taken in this game")
      expect(checked_colors).to eq([presets[1]])
      expect(radio_for("#E74C3C")["checked"]).to be_nil
    end
  end
end
