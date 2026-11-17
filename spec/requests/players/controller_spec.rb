require "rails_helper"

RSpec.describe "Players" do
  include_context "players"

  describe "GET /games/:code/controller" do
    it "shows the controller view after joining" do
      post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alice")
    end

    it "links How to play back to this game by its code" do
      post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
      get game_controller_path(game.code)
      expect(response.body).to include(%(href="#{how_to_play_path(game: game.code)}"))
    end

    it "returns 404 with no valid cookie" do
      get game_controller_path(game.code)
      expect(response).to have_http_status(:not_found)
    end

    context "the landscape board strip" do
      let(:me) { game.players.find_by!(name: "Alice") }
      let!(:bob) { game.players.create!(name: "Bob", color: "#3498DB", last_seen_at: Time.current) }
      let(:status) { Nokogiri::HTML(response.body).at_css("#controller_status") }
      let(:card_svgs) { status.css("svg").select { |svg| svg.ancestors("[class*='aspect-[5/7]']").any? } }

      before do
        post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
        game.start!
      end

      def show
        get game_controller_path(game.code)
        expect(response).to have_http_status(:ok)
      end

      def expect_read_only_board
        expect(card_svgs.size).to eq(game.board.size)
        expect(status.css("button[data-card-id]")).to be_empty
        card_svgs.each { |svg| expect(svg.ancestors("form")).to be_empty }
      end

      it "makes each idle card a button with data-card-id in a form posting the claim" do
        show
        buttons = status.css("button[data-card-id]")
        expect(buttons.map { |b| b["data-card-id"].to_i }).to eq(game.board)
        buttons.each do |b|
          expect(b["class"]).to include("cursor-pointer")
          expect(b.ancestors("form").first["action"]).to eq(game_claims_path(game.code))
        end
      end

      it "keeps the board read-only while locked out" do
        me.update!(locked_until: 5.seconds.from_now)
        show
        expect_read_only_board
      end

      it "keeps the board read-only while someone else claims" do
        game.try_claim!(bob)
        show
        expect(status.text).to include("is calling SET!")
        expect_read_only_board
      end

      it "posts picks to the running claim, not a leftover one from an earlier game" do
        leftover = game.try_claim!(me)
        game.update!(status: :ended)
        game.restart!
        running = game.try_claim!(me)
        show
        selection = status.at_css("[data-controller='card-selection']")
        expect(selection["data-card-selection-url-value"]).to eq(game_claim_path(game.code, running.id))
        expect(selection["data-card-selection-submit-url-value"]).to eq(submit_game_claim_path(game.code, running.id))
        expect(leftover.reload).to be_pending
      end

      it "keeps the board read-only during a No Set countdown" do
        game.call_no_set!(bob)
        show
        expect(status.text).to include("No Set called by")
        expect_read_only_board
      end
    end
  end
end
