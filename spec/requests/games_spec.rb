require "rails_helper"

RSpec.describe "Games" do
  describe "POST /games" do
    it "creates a game and redirects to the creator's join page" do
      expect { post games_path }.to change(Game, :count).by(1)
      expect(response).to redirect_to(join_game_players_path(Game.last.code))
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

    it "creates a standard game when mode=standard" do
      post games_path, params: {mode: "standard"}
      expect(Game.last).to be_standard
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

    describe "announcement band" do
      before { game.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a) }

      it "invites a SET! call on your screen while idle" do
        get game_path(game.code)
        expect(response.body).to include("Spot a Set? Hit SET! on your screen.")
        expect(response.body).not_to include("on your phone")
      end

      it "asks to agree on your screen during a No Set call" do
        alice = game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current)
        game.update!(no_set_caller_id: alice.id, no_set_started_at: Time.current, no_set_voters: [alice.id])
        get game_path(game.code)
        expect(response.body).to include("Agree on your screen, or find one first")
        expect(response.body).not_to include("on your phone")
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

      it "restarts at once with votes pending and clears them" do
        @game.update!(start_voters: [123])
        post restart_game_path(@game.code)
        expect(@game.reload).to be_playing
        expect(@game.start_voters).to be_empty
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

    context "once ended" do
      let!(:alice) { sign_in_player }
      let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current) }

      before { game.start! && game.update!(status: :ended, deck: []) }

      it "records the vote and answers 204, a repeat changing nothing" do
        post ready_game_path(game.code)
        post ready_game_path(game.code)
        expect(response).to have_http_status(:no_content)
        expect(game.reload.start_voters).to eq([alice.id])
        expect(game).to be_ended
      end

      it "restarts the room once every active player has voted" do
        game.update!(start_voters: [bob.id])
        post ready_game_path(game.code)
        expect(game.reload).to be_playing
        expect(game.start_voters).to be_empty
      end

      it "marks the voter seen, so an idle voter counts for their own vote" do
        alice.update_column(:last_seen_at, 1.minute.ago)
        bob.update_column(:last_seen_at, 1.minute.ago)
        post ready_game_path(game.code)
        expect(alice.reload.last_seen_at).to be > 5.seconds.ago
        expect(game.reload).to be_playing
      end

      it "shows a Play again button on the player screen" do
        get game_controller_path(game.code)
        status = Nokogiri::HTML(response.body).at_css("#controller_status")
        expect(status.at_css("form[action='#{ready_game_path(game.code)}'] button").text).to include("Play again")
        expect(status.text).not_to include("Play again from the big screen")
      end

      it "shows the waiting line after voting, without the button" do
        post ready_game_path(game.code)
        get game_controller_path(game.code)
        status = Nokogiri::HTML(response.body).at_css("#controller_status")
        expect(status.text).to include("Ready ✓ · waiting for 1 more")
        expect(status.at_css("form[action='#{ready_game_path(game.code)}']")).to be_nil
      end
    end

    it "changes nothing while playing" do
      sign_in_player
      game.players.create!(name: "Bob", color: "#2ECC71")
      game.start!
      post ready_game_path(game.code)
      expect(response).to have_http_status(:no_content)
      expect(game.reload).to be_playing
      expect(game.start_voters).to be_empty
    end

    it "returns 403 without a valid player cookie" do
      post ready_game_path(game.code)
      expect(response).to have_http_status(:forbidden)
    end
  end

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
    let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71") }
    let!(:cleo) { game.players.create!(name: "Cleo", color: "#F1C40F") }

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
