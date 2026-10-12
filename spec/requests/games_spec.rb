require "rails_helper"

RSpec.describe "Games" do
  describe "POST /games" do
    it "creates a game and redirects to its board" do
      expect { post games_path }.to change(Game, :count).by(1)
      expect(response).to redirect_to(game_path(Game.last.code))
    end

    it "sets the host cookie" do
      post games_path
      expect(cookies[:host_game]).to be_present
    end

    it "creates a standard game by default" do
      post games_path
      expect(Game.last).to be_standard
    end

    it "creates a quick game when mode=quick" do
      post games_path, params: {mode: "quick"}
      expect(Game.last).to be_quick
    end

    context "when rate limited" do
      # The test env uses a null cache store, so count in a real one.
      let(:store) { ActiveSupport::Cache::MemoryStore.new }

      before do
        allow(GamesController.cache_store).to receive(:increment) { |*args, **opts| store.increment(*args, **opts) }
      end

      it "returns 429 after 10 requests a minute" do
        10.times { post games_path }
        expect(response).not_to have_http_status(:too_many_requests)

        expect { post games_path }.not_to change(Game, :count)
        expect(response).to have_http_status(:too_many_requests)
        expect(response.body).to include("Try again in a minute.")
      end
    end
  end

  describe "GET /games/:code" do
    let(:game) { Game.create! }

    it "returns 200 and shows the room code" do
      get game_path(game.code)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(game.code)
    end

    it "returns 404 for an unknown code" do
      get game_path("XXXXXX")
      expect(response).to have_http_status(:not_found)
    end

    def qr_svgs = Nokogiri::HTML(response.body).css("svg[shape-rendering='crispEdges']")
    def room_tile = Nokogiri::HTML(response.body).at_css("#room_tile")

    it "shows only the hero QR and no room tile while waiting" do
      get game_path(game.code)
      expect(qr_svgs.size).to eq(1)
      expect(qr_svgs.first["class"]).to include("size-72")
      expect(room_tile.text.strip).to be_empty
    end

    it "keeps the QR modules dark on a white tile" do
      get game_path(game.code)
      expect(qr_svgs.first.at_css("path")["fill"]).to eq("#030712")
      expect(qr_svgs.first.parent["class"]).to include("bg-white")
    end

    def join_link(html = response.body) = Nokogiri::HTML(html).css("a").find { |a| a.text.include?("Join from this computer") }

    it "links to the join page in a new tab while waiting" do
      get game_path(game.code)
      link = join_link
      expect(link).to be_present
      expect(link["href"]).to eq(join_game_players_path(game.code))
      expect(link["target"]).to eq("_blank")
      expect(link["rel"].split).to include("noopener")
    end

    describe "waiting board broadcast" do
      include Turbo::Broadcastable::TestHelper

      it "keeps the join link when a player joins" do
        streams = capture_turbo_stream_broadcasts("game:#{game.code}") do
          game.players.create!(name: "Alice", color: "#648FFF")
        end
        board = streams.find { |s| s["target"] == "board" }
        expect(join_link(board.to_html)["href"]).to eq(join_game_players_path(game.code))
      end
    end

    %i[playing ended].each do |state|
      it "shows no join link while #{state}" do
        game.update!(status: state, board: (0..11).to_a, deck: (12..80).to_a)
        get game_path(game.code)
        expect(join_link).to be_nil
      end

      it "shows the room tile with no QR while #{state}" do
        game.update!(status: state, board: (0..11).to_a, deck: (12..80).to_a)
        get game_path(game.code)
        expect(qr_svgs).to be_empty
        expect(room_tile.text).to include("Room", game.code, "www.example.com")
      end
    end
  end

  describe "POST /games/:code/start" do
    let(:game) { Game.create! }

    context "as the host" do
      before do
        post games_path  # sets host cookie
        @game = Game.last
        @game.players.create!(name: "Alice", color: "#648FFF", session_token: SecureRandom.hex)
        @game.players.create!(name: "Bob", color: "#FE6100", session_token: SecureRandom.hex)
      end

      it "transitions the game to playing" do
        post start_game_path(@game.code)
        expect(@game.reload).to be_playing
      end

      it "deals 12 cards to the board" do
        post start_game_path(@game.code)
        expect(@game.reload.board.size).to eq(12)
      end

      it "answers 204 so the board is not reloaded" do
        post start_game_path(@game.code)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "as a non-host" do
      it "returns 403" do
        post start_game_path(game.code)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /games/:code/restart" do
    context "as the host" do
      before do
        post games_path
        @game = Game.last
        @game.update!(status: :ended, board: [], deck: [], discard: [])
      end

      it "transitions the game to playing" do
        post restart_game_path(@game.code)
        expect(@game.reload).to be_playing
      end

      it "deals 12 cards to the board" do
        post restart_game_path(@game.code)
        expect(@game.reload.board.size).to eq(12)
      end

      it "answers 204 so the board is not reloaded" do
        post restart_game_path(@game.code)
        expect(response).to have_http_status(:no_content)
      end

      it "resets player scores" do
        player = @game.players.create!(name: "Alice", color: "#648FFF", score: 5)
        post restart_game_path(@game.code)
        expect(player.reload.score).to eq(0)
      end
    end

    context "as a non-host" do
      let(:game) { Game.create! }

      it "returns 403" do
        post restart_game_path(game.code)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /games/:code/ready" do
    let(:game) { Game.create! }

    def sign_in_player(name: "Alice", color: "#E74C3C")
      post game_players_path(game.code), params: {player: {name: name, color: color}}
      game.players.find_by!(name: name)
    end

    it "records the player's vote without starting the game when others haven't voted" do
      player = sign_in_player
      game.players.create!(name: "Bob", color: "#2ECC71")
      post ready_game_path(game.code)
      expect(game.reload.start_voters).to include(player.id)
      expect(game.reload).to be_waiting
      expect(response).to have_http_status(:no_content)
    end

    it "starts the game when all players have voted" do
      sign_in_player
      bob = game.players.create!(name: "Bob", color: "#2ECC71", session_token: SecureRandom.hex)
      post ready_game_path(game.code)  # Alice votes via cookie
      game.vote_start!(bob)            # Bob votes directly
      expect(game.reload).to be_playing
    end

    it "does not start the game when only some players have voted" do
      sign_in_player
      game.players.create!(name: "Bob", color: "#2ECC71")
      post ready_game_path(game.code)
      expect(game.reload).to be_waiting
    end

    it "returns 403 without a valid player cookie" do
      post ready_game_path(game.code)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
