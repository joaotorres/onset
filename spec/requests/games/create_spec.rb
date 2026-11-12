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
end
