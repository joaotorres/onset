require "rails_helper"

# SPEC.md §5, Rate limits (ticket 60). The test environment's cache store is
# :null_store, so the limits count in a MemoryStore standing in for it.
RSpec.describe "In-game rate limits" do
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { ActiveSupport::Cache::MemoryStore.new }
  let(:game) { Game.create! }
  let(:alice) { join("Alice", "#E74C3C") }
  let(:bob) { join("Bob", "#2ECC71") }

  before do
    allow(GamesController.cache_store).to receive(:increment) { |*args, **opts| store.increment(*args, **opts) }
  end

  # A browser of its own, so each player has its own cookies; every one shares the IP.
  def join(name, color)
    session = open_session
    session.post game_players_path(game.code), params: {player: {name: name, color: color}}
    session
  end

  def token_of(name)
    game.players.find_by!(name: name).session_token
  end

  def play!
    alice && bob
    game.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: [])
  end

  # Counts n requests already made in this minute under the key a limit uses.
  def preload(scope, name, by, n)
    store.increment(["rate-limit", scope, name, by].compact.join(":"), n, expires_in: 1.minute)
  end

  def valid_set_ids
    game.board_cards.combination(3).find { |trio| Card.valid_set?(*trio) }.map(&:id)
  end

  describe "claims" do
    before { play! }

    it "counts SET!, picks and Submit as one 180 a minute, then refuses and changes nothing" do
      preload("claims", "claims", token_of("Alice"), 177)

      alice.post game_claims_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      claim = game.claims.last
      alice.patch game_claim_path(game.code, claim), params: {card_ids: valid_set_ids.first(2)}
      expect(alice.response).to have_http_status(:no_content)
      alice.patch game_claim_path(game.code, claim), params: {card_ids: valid_set_ids}
      expect(alice.response).to have_http_status(:no_content)

      alice.patch game_claim_path(game.code, claim), params: {card_ids: valid_set_ids.first(1)}
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(alice.response.body).to be_empty
      expect(claim.reload.card_ids).to eq(valid_set_ids)

      alice.post submit_game_claim_path(game.code, claim), params: {card_ids: valid_set_ids}
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(claim.reload).to be_pending
    end

    it "takes no claim for a refused SET!" do
      preload("claims", "claims", token_of("Alice"), 180)
      expect { alice.post game_claims_path(game.code) }.not_to change(Claim, :count)
      expect(alice.response).to have_http_status(:too_many_requests)
    end

    it "counts each player apart although they share an IP" do
      preload("claims", "claims", token_of("Alice"), 180)
      bob.post game_claims_path(game.code)
      expect(bob.response).to have_http_status(:no_content)
      expect(game.claims.count).to eq(1)
    end

    it "is a count of its own: ready, No Set and End game still answer at the claims limit" do
      preload("claims", "claims", token_of("Alice"), 180)
      alice.post ready_game_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      alice.post game_no_set_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      alice.post game_end_game_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
    end

    it "answers again once the minute has passed" do
      preload("claims", "claims", token_of("Alice"), 180)
      alice.post game_claims_path(game.code)
      expect(alice.response).to have_http_status(:too_many_requests)

      travel 61.seconds
      alice.post game_claims_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
    end
  end

  describe "ready" do
    before { play! }

    it "answers up to 30 a minute and refuses the 31st, counting no vote" do
      preload("games", "ready", token_of("Alice"), 29)
      alice.post ready_game_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      alice.post ready_game_path(game.code)
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(alice.response.body).to be_empty
    end

    it "does not count a vote on a refused request" do
      game.update!(status: :ended)
      preload("games", "ready", token_of("Alice"), 30)
      alice.post ready_game_path(game.code)
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(game.reload.start_voters).to be_empty
    end

    it "counts each player apart although they share an IP" do
      preload("games", "ready", token_of("Alice"), 30)
      bob.post ready_game_path(game.code)
      expect(bob.response).to have_http_status(:no_content)
    end
  end

  describe "No Set" do
    before { play! }

    it "counts call, withdraw and There's a Set as one, 30 a minute" do
      preload("no_sets", "no_set", token_of("Alice"), 28)
      alice.post game_no_set_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      alice.delete game_no_set_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      alice.post refuse_game_no_set_path(game.code)
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(alice.response.body).to be_empty
    end

    it "starts no call on a refused request" do
      preload("no_sets", "no_set", token_of("Alice"), 30)
      alice.post game_no_set_path(game.code)
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(game.reload).not_to be_no_set_active
    end

    it "counts each player apart although they share an IP" do
      preload("no_sets", "no_set", token_of("Alice"), 30)
      bob.post game_no_set_path(game.code)
      expect(bob.response).to have_http_status(:no_content)
    end
  end

  describe "End game" do
    before { play! }

    it "answers up to 30 a minute and refuses the 31st, counting no vote" do
      preload("end_games", "end_game", token_of("Alice"), 29)
      alice.post game_end_game_path(game.code)
      expect(alice.response).to have_http_status(:no_content)
      game.update!(end_game_voters: [])
      alice.post game_end_game_path(game.code)
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(game.reload.end_game_voters).to be_empty
    end

    it "counts each player apart although they share an IP" do
      preload("end_games", "end_game", token_of("Alice"), 30)
      bob.post game_end_game_path(game.code)
      expect(bob.response).to have_http_status(:no_content)
    end
  end

  describe "the host's Start game and Play again" do
    let(:host) { open_session }
    let(:code) { Game.last.code }

    before do
      host.post games_path
      join_to(code, "Alice", "#E74C3C")
      join_to(code, "Bob", "#2ECC71")
    end

    def join_to(code, name, color)
      open_session.post game_players_path(code), params: {player: {name: name, color: color}}
    end

    it "counts both as one, 30 a minute, and a refused one leaves the status alone" do
      preload("games", "host", code, 29)
      host.post start_game_path(code)
      expect(host.response).to have_http_status(:no_content)
      expect(Game.find_by!(code: code)).to be_playing

      host.post restart_game_path(code)
      expect(host.response).to have_http_status(:too_many_requests)
      expect(host.response.body).to be_empty
      expect(Game.find_by!(code: code)).to be_playing
    end

    it "does not start a game on a refused Start game" do
      preload("games", "host", code, 30)
      host.post start_game_path(code)
      expect(host.response).to have_http_status(:too_many_requests)
      expect(Game.find_by!(code: code)).to be_waiting
    end

    it "does not count a stranger's 403s, from another IP, against the host" do
      stranger = open_session
      30.times { stranger.post start_game_path(code), env: {"REMOTE_ADDR" => "9.9.9.9"} }
      expect(stranger.response).to have_http_status(:too_many_requests).or have_http_status(:forbidden)

      host.post start_game_path(code)
      expect(host.response).to have_http_status(:no_content)
    end
  end

  describe "an unknown room code (ticket 79)" do
    it "counts a ready request before the room lookup" do
      play!
      preload("games", "ready", token_of("Alice"), 29)
      alice.post ready_game_path("NOROOM")
      expect(alice.response).to have_http_status(:not_found)
      alice.post ready_game_path("NOROOM")
      expect(alice.response).to have_http_status(:too_many_requests)
      expect(alice.response.body).to be_empty
    end

    it "counts the host's Start game before the room lookup" do
      host = open_session
      host.post games_path
      code = Game.last.code
      preload("games", "host", code, 29)
      host.post start_game_path("NOROOM")
      expect(host.response).to have_http_status(:not_found)
      host.post start_game_path("NOROOM")
      expect(host.response).to have_http_status(:too_many_requests)
      expect(host.response.body).to be_empty
    end
  end

  it "still answers SET! for a player at the No Set limit, and takes the claim" do
    play!
    preload("no_sets", "no_set", token_of("Alice"), 30)
    expect { alice.post game_claims_path(game.code) }.to change(Claim, :count).by(1)
    expect(alice.response).to have_http_status(:no_content)
  end

  describe "a refused request broadcasts nothing" do
    include Turbo::Broadcastable::TestHelper

    before { play! }

    def expect_silent(session)
      player_id = game.players.find_by!(name: "Alice").id
      player_streams = nil
      game_streams = capture_turbo_stream_broadcasts("game:#{game.code}") do
        player_streams = capture_turbo_stream_broadcasts("player:#{player_id}") { yield }
      end
      expect(session.response).to have_http_status(:too_many_requests)
      expect(game_streams).to be_empty
      expect(player_streams).to be_empty
    end

    it "for claims" do
      preload("claims", "claims", token_of("Alice"), 180)
      expect_silent(alice) { alice.post game_claims_path(game.code) }
    end

    it "for ready" do
      game.update!(status: :ended)
      preload("games", "ready", token_of("Alice"), 30)
      expect_silent(alice) { alice.post ready_game_path(game.code) }
    end

    it "for No Set" do
      preload("no_sets", "no_set", token_of("Alice"), 30)
      expect_silent(alice) { alice.post game_no_set_path(game.code) }
    end

    it "for End game" do
      preload("end_games", "end_game", token_of("Alice"), 30)
      expect_silent(alice) { alice.post game_end_game_path(game.code) }
    end

    it "for the host's Start game and Play again" do
      host = open_session
      host.post games_path
      hosted = Game.last
      join_to_game(hosted, "Cy", "#9B59B6")
      join_to_game(hosted, "Di", "#F1C40F")
      preload("games", "host", hosted.code, 30)
      player_id = hosted.players.find_by!(name: "Cy").id
      player_streams = nil
      game_streams = capture_turbo_stream_broadcasts("game:#{hosted.code}") do
        player_streams = capture_turbo_stream_broadcasts("player:#{player_id}") do
          host.post start_game_path(hosted.code)
          host.post restart_game_path(hosted.code)
        end
      end
      expect(host.response).to have_http_status(:too_many_requests)
      expect(game_streams).to be_empty
      expect(player_streams).to be_empty
    end

    def join_to_game(g, name, color)
      session = open_session
      session.post game_players_path(g.code), params: {player: {name: name, color: color}}
      session
    end
  end

  describe "a request with no player cookie is counted by IP" do
    before { play! }

    # A cookie-less request is refused today with 403 or 404.
    def expect_refused_as_today(session)
      expect([403, 404]).to include(session.response.status)
    end

    [
      ["claims", "claims", 180, :game_claims_path],
      ["games", "ready", 30, :ready_game_path],
      ["no_sets", "no_set", 30, :game_no_set_path],
      ["end_games", "end_game", 30, :game_end_game_path]
    ].each do |scope, name, limit, route|
      it "for #{name}: refused at the IP's limit, a second IP and the cookie holder answered as today" do
        preload(scope, name, "127.0.0.1", limit)
        path = send(route, game.code)

        stranger = open_session
        stranger.post path
        expect(stranger.response).to have_http_status(:too_many_requests)

        stranger.post path, env: {"REMOTE_ADDR" => "9.9.9.9"}
        expect_refused_as_today(stranger)

        alice.post path
        expect(alice.response).to have_http_status(:no_content)
      end

      it "for #{name}: a player at the limit leaves the IP's count alone" do
        preload(scope, name, token_of("Alice"), limit)
        stranger = open_session
        stranger.post send(route, game.code)
        expect_refused_as_today(stranger)
      end
    end
  end

  describe "a Start game with no host cookie is counted by IP" do
    let(:host) { open_session }
    let(:code) { Game.last.code }

    before do
      host.post games_path
      2.times { |i| open_session.post game_players_path(code), params: {player: {name: "P#{i}", color: ["#E74C3C", "#2ECC71"][i]}} }
    end

    it "refuses at the IP's limit, answers a second IP 403 and the host as today" do
      preload("games", "host", "127.0.0.1", 30)
      stranger = open_session
      stranger.post start_game_path(code)
      expect(stranger.response).to have_http_status(:too_many_requests)

      stranger.post start_game_path(code), env: {"REMOTE_ADDR" => "9.9.9.9"}
      expect(stranger.response).to have_http_status(:forbidden)

      host.post start_game_path(code)
      expect(host.response).to have_http_status(:no_content)
    end
  end

  it "leaves the room-creation limit at 10 a minute per IP" do
    10.times { post games_path }
    expect(response).to have_http_status(:found)
    post games_path
    expect(response).to have_http_status(:too_many_requests)
  end
end
