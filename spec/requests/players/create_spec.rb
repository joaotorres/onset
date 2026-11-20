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
