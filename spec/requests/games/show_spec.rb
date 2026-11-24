require "rails_helper"

RSpec.describe "Games" do
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

    it "shows only the hero QR and, in the room tile's place, the add-bot control while waiting" do
      get game_path(game.code)
      expect(qr_svgs.size).to eq(1)
      expect(qr_svgs.first["class"]).to include("size-72")
      expect(room_tile.text).not_to include("Room", game.code, "www.example.com")
      expect(room_tile.at_css("[aria-label='Add a bot']")).to be_present
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
          create_player(game, name: "Alice")
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
        alice = create_player(game, name: "Alice", last_seen_at: Time.current)
        game.update!(no_set_caller_id: alice.id, no_set_started_at: Time.current, no_set_voters: [alice.id])
        get game_path(game.code)
        expect(response.body).to include("Agree on your screen, or find one first")
        expect(response.body).not_to include("on your phone")
      end

      it "reads the No Set ring's duration from NO_SET_TIMEOUT" do
        stub_const("Game::NO_SET_TIMEOUT", 20)
        alice = create_player(game, name: "Alice", last_seen_at: Time.current)
        game.update!(no_set_caller_id: alice.id, no_set_started_at: Time.current, no_set_voters: [alice.id])
        get game_path(game.code)
        ring = Nokogiri::HTML(response.body).at_css("#announcement [data-controller=countdown]")
        expect(ring["data-countdown-duration-value"]).to eq("20")
      end

      context "during the block after a refusal" do
        include ActiveSupport::Testing::TimeHelpers

        let(:bob) { create_player(game, name: "Bob", last_seen_at: Time.current) }
        let(:band) { Nokogiri::HTML(response.body).at_css("#announcement") }

        before { game.update!(no_set_refuser_id: bob.id, no_set_refused_at: 3.seconds.ago) }

        it "shows one purple Refused panel with the block's ring and the refuser" do
          get game_path(game.code)
          ring = band.at_css("[data-controller=countdown]")
          expect(ring["data-countdown-started-at-value"]).to eq(game.reload.no_set_refused_at.iso8601)
          expect(ring["data-countdown-duration-value"]).to eq(Game::NO_SET_TIMEOUT.to_s)
          expect(ring.at_css(".stroke-purple-400")).to be_present
          expect(ring.at_css("[data-countdown-target=display]")["class"]).to include("text-purple-300")
          expect(band.text.squish).to include("Bob says there's a Set", "No Set is back when the ring runs out")
          name = band.css("span.text-purple-400").find { |n| n.text.strip == "Bob" }
          expect(name).to be_present
          expect(name["class"]).to include("truncate")
          expect(band.text).not_to include("agreed")
          expect(band.text).not_to include("Spot a Set?")
        end

        it "shows the Claiming panel while a claim runs" do
          game.try_claim!(bob)
          get game_path(game.code)
          expect(band.text).to include("is calling SET!")
          expect(band.text).not_to include("says there's a Set")
        end

        it "shows the idle text once the block is over" do
          game.update!(no_set_refused_at: (Game::NO_SET_TIMEOUT + 1).seconds.ago)
          get game_path(game.code)
          expect(band.text.squish).to include("Spot a Set? Hit SET! on your screen.")
          expect(band.text).not_to include("says there's a Set")
        end
      end

      context "after a wrong claim or a time's up" do
        let(:alice) { create_player(game, name: "Alice", last_seen_at: Time.current) }

        def flash(result, card_ids)
          claim = game.claims.create!(player: alice, result: result, card_ids: card_ids, started_at: Time.current, resolved_at: Time.current)
          game.update!(flash_claim_id: claim.id)
          get game_path(game.code)
          Nokogiri::HTML(response.body).at_css("#announcement").text.squish
        end

        it "names the lockout length from the claim time on a wrong claim" do
          expect(flash(:wrong, [0, 1, 2])).to include("Not a Set · locked out for #{Game::CLAIM_TIMEOUT} seconds")
        end

        it "names the lockout length from the claim time on a time's up" do
          expect(flash(:expired, [0])).to include("ran out · locked out for #{Game::CLAIM_TIMEOUT} seconds")
        end
      end
    end
  end
end
