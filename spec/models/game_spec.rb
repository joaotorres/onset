require "rails_helper"

RSpec.describe Game do
  include ActiveSupport::Testing::TimeHelpers

  describe "code generation" do
    it "generates a code on create" do
      game = Game.create!
      expect(game.code).to be_present
    end

    it "generates a code matching the allowed format" do
      game = Game.create!
      expect(game.code).to match(Game::CODE_FORMAT)
    end

    it "generates a 6-character code" do
      game = Game.create!
      expect(game.code.length).to eq(6)
    end

    it "never generates a code with confusable glyphs (0, O, 1, I)" do
      50.times do
        game = Game.create!
        expect(game.code).not_to match(/[01OI]/)
      end
    end

    it "does not overwrite a code that was explicitly set" do
      game = Game.create!(code: "ABC234")
      expect(game.code).to eq("ABC234")
    end
  end

  describe "validations" do
    it "is invalid without a code" do
      game = Game.create!
      game.code = nil
      expect(game).not_to be_valid
    end

    it "is invalid with a duplicate code" do
      Game.create!(code: "AAA222")
      duplicate = Game.new(code: "AAA222")
      expect(duplicate).not_to be_valid
    end

    it "is invalid when code contains a confusable glyph" do
      expect(Game.new(code: "AAAA01")).not_to be_valid
      expect(Game.new(code: "AAAOOI")).not_to be_valid
    end

    it "is invalid when code is not 6 characters" do
      expect(Game.new(code: "AAA22")).not_to be_valid
      expect(Game.new(code: "AAA2222")).not_to be_valid
    end
  end

  describe "uniqueness by construction" do
    it "generates distinct codes for concurrent creates" do
      games = 10.times.map { Game.create! }
      expect(games.map(&:code).uniq.size).to eq(10)
    end
  end

  describe "#start!" do
    let(:game) { Game.create! }

    it "sets status to playing" do
      game.start!
      expect(game.reload).to be_playing
    end

    it "puts 12 cards on the board" do
      game.start!
      expect(game.reload.board.size).to eq(12)
    end

    it "puts the remaining 69 cards in the deck" do
      game.start!
      expect(game.reload.deck.size).to eq(69)
    end

    it "uses all 81 unique card ids across board and deck" do
      game.start!
      game.reload
      expect((game.board + game.deck).sort).to eq((0..80).to_a)
    end

    it "sets discard to empty" do
      game.start!
      expect(game.reload.discard).to be_empty
    end

    it "shuffles differently each time" do
      game.start!
      first_board = game.board.dup
      game2 = Game.create!
      game2.start!
      expect(game2.board).not_to eq(first_board)
    end
  end

  describe "#board_cards" do
    it "returns Card objects for each board id" do
      game = Game.create!
      game.start!
      cards = game.board_cards
      expect(cards.size).to eq(12)
      expect(cards).to all(be_a(Card))
      expect(cards.map(&:id)).to eq(game.board)
    end
  end

  describe "#try_claim!" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:player) { game.players.create!(name: "Alice", color: "#E74C3C") }

    it "returns a pending claim and locks the game" do
      claim = game.try_claim!(player)
      expect(claim).to be_a(Claim)
      expect(claim).to be_pending
      expect(game.reload.claim_player_id).to eq(player.id)
    end

    it "returns nil when game is not playing" do
      game.update!(status: :waiting)
      expect(game.try_claim!(player)).to be_nil
    end

    it "returns nil when another claim is already active" do
      game.try_claim!(player)
      other = game.players.create!(name: "Bob", color: "#2ECC71")
      expect(game.try_claim!(other)).to be_nil
    end

    it "returns nil when the player is locked out" do
      player.update!(locked_until: 1.second.from_now)
      expect(game.try_claim!(player)).to be_nil
    end

    it "claims once the lockout has passed" do
      player.update!(locked_until: 1.second.ago)
      expect(game.try_claim!(player)).to be_present
    end

    it "cancels an active No-Set when a claim is acquired" do
      game.update!(no_set_caller_id: player.id, no_set_started_at: Time.current, no_set_voters: [player.id])
      game.try_claim!(player)
      expect(game.reload.no_set_active?).to be false
    end

    describe "near-tie log" do
      let(:bob) { game.players.create!(name: "Bob", color: "#2ECC71") }

      def near_tie_lines
        lines = []
        allow(Rails.logger).to receive(:info) { |msg = nil, &blk| lines << (msg || blk&.call).to_s }
        yield
        lines.grep(/near_tie/)
      end

      it "logs how late a call lost to a running claim arrived" do
        game.try_claim!(player)
        game.reload
        lines = near_tie_lines { expect(game.try_claim!(bob, arrived_at: game.claim_started_at + 0.183)).to be_nil }
        expect(lines).to eq(["near_tie game=#{game.code} winner=#{player.id} loser=#{bob.id} late_ms=183"])
      end

      it "logs a negative gap when the call arrived before the claim was stamped" do
        game.try_claim!(player)
        game.reload
        lines = near_tie_lines { game.try_claim!(bob, arrived_at: game.claim_started_at - 0.02) }
        expect(lines).to eq(["near_tie game=#{game.code} winner=#{player.id} loser=#{bob.id} late_ms=-20"])
      end

      it "logs nothing when the call wins" do
        expect(near_tie_lines { game.try_claim!(bob) }).to be_empty
      end

      it "logs nothing for a locked-out player while a claim runs" do
        game.try_claim!(player)
        bob.update!(locked_until: 1.second.from_now)
        expect(near_tie_lines { expect(game.try_claim!(bob)).to be_nil }).to be_empty
      end

      it "logs nothing when the game is not playing" do
        game.try_claim!(player)
        game.update!(status: :waiting)
        expect(near_tie_lines { expect(game.try_claim!(bob)).to be_nil }).to be_empty
      end

      it "logs nothing for a locked-out player with no claim running" do
        bob.update!(locked_until: 1.second.from_now)
        expect(near_tie_lines { expect(game.try_claim!(bob)).to be_nil }).to be_empty
      end
    end
  end

  describe "#call_no_set!" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:player) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }

    it "sets no_set fields and returns the game" do
      result = game.call_no_set!(player)
      game.reload
      expect(result).to eq(game)
      expect(game.no_set_active?).to be true
      expect(game.no_set_caller_id).to eq(player.id)
      expect(game.no_set_voters).to eq([player.id])
    end

    it "returns nil when the game is not playing" do
      game.update!(status: :waiting)
      expect(game.call_no_set!(player)).to be_nil
    end

    it "returns nil when a claim is active" do
      game.update!(claim_player_id: player.id, claim_started_at: Time.current)
      expect(game.call_no_set!(player)).to be_nil
    end

    it "returns nil when a No-Set is already active" do
      game.call_no_set!(player)
      other = game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current)
      expect(game.call_no_set!(other)).to be_nil
    end
  end

  describe "#join_no_set!" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:alice) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }
    let(:bob) { game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current) }
    let(:charlie) { game.players.create!(name: "Charlie", color: "#DC267F", last_seen_at: Time.current) }

    before {
      alice
      bob
      charlie
      game.call_no_set!(alice)
    }

    it "adds the player to no_set_voters" do
      game.join_no_set!(bob)
      expect(game.reload.no_set_voters).to include(bob.id)
    end

    it "is idempotent — does not double-add a voter" do
      game.join_no_set!(alice)
      expect(game.reload.no_set_voters.count(alice.id)).to eq(1)
    end

    it "returns nil when no No-Set is active" do
      game.cancel_no_set!
      expect(game.join_no_set!(bob)).to be_nil
    end

    it "resolves immediately when all active players have voted" do
      old_board_size = game.board.size
      game.join_no_set!(bob)
      game.join_no_set!(charlie)
      game.reload
      expect(game.no_set_active?).to be false
      expect(game.board.size).to be > old_board_size
    end
  end

  describe "#cancel_no_set!" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:player) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }

    it "clears all no_set fields" do
      game.call_no_set!(player)
      game.cancel_no_set!
      game.reload
      expect(game.no_set_active?).to be false
      expect(game.no_set_caller_id).to be_nil
      expect(game.no_set_voters).to be_empty
    end
  end

  describe "#resolve_no_set!" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:player) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }

    before { game.call_no_set!(player) }

    it "deals 3 more cards to the board" do
      expect { game.resolve_no_set! }.to change { game.reload.board.size }.by(3)
    end

    it "removes dealt cards from the deck" do
      expect { game.resolve_no_set! }.to change { game.reload.deck.size }.by(-3)
    end

    it "clears no_set fields" do
      game.resolve_no_set!
      game.reload
      expect(game.no_set_active?).to be false
    end

    it "records the added cards as just dealt" do
      dealt = game.deck.first(3)
      game.resolve_no_set!
      expect(game.reload.last_dealt).to eq(dealt)
    end

    it "caps board at 18 cards" do
      game.update!(board: (0..17).to_a, deck: (18..80).to_a)
      game.resolve_no_set!
      game.reload
      expect(game.board.size).to eq(18)
    end

    it "does not deal past 18 when board is already at 18" do
      game.update!(board: (0..17).to_a, deck: (18..80).to_a)
      game.resolve_no_set!
      expect(game.reload.board.size).to eq(18)
    end

    it "deals fewer than 3 cards when deck is nearly empty" do
      game.update!(deck: [80])
      game.resolve_no_set!
      game.reload
      expect(game.deck).to be_empty
    end
  end

  describe "#restart!" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:alice) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }
    let(:bob) { game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current) }

    before do
      alice.update!(score: 3, locked_until: 1.minute.from_now)
      bob.update!(score: -1)
      game.update!(
        status: :ended,
        claim_player_id: alice.id,
        claim_started_at: Time.current,
        no_set_caller_id: bob.id,
        no_set_started_at: Time.current,
        no_set_voters: [bob.id]
      )
    end

    it "sets status to playing" do
      game.restart!
      expect(game.reload).to be_playing
    end

    it "deals 12 cards to the board" do
      game.restart!
      expect(game.reload.board.size).to eq(12)
    end

    it "puts 69 cards in the deck" do
      game.restart!
      expect(game.reload.deck.size).to eq(69)
    end

    it "uses all 81 unique card ids across board and deck" do
      game.restart!
      game.reload
      expect((game.board + game.deck).sort).to eq((0..80).to_a)
    end

    it "resets discard to empty" do
      game.restart!
      expect(game.reload.discard).to be_empty
    end

    it "resets all player scores to 0" do
      game.restart!
      expect(alice.reload.score).to eq(0)
      expect(bob.reload.score).to eq(0)
    end

    it "clears player lockouts" do
      game.restart!
      expect(alice.reload.locked_until).to be_nil
    end

    it "clears claim state" do
      game.restart!
      game.reload
      expect(game.claim_player_id).to be_nil
      expect(game.claim_started_at).to be_nil
    end

    it "clears no-set state" do
      game.restart!
      game.reload
      expect(game.no_set_caller_id).to be_nil
      expect(game.no_set_started_at).to be_nil
      expect(game.no_set_voters).to be_empty
    end
  end

  describe "#vote_play_again!" do
    let(:game) { Game.create!(mode: :quick).tap(&:start!) }
    let!(:alice) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current, score: 4) }
    let!(:bob) { game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current, score: 5) }

    before { game.update!(status: :ended, deck: [], board: [1, 2, 3]) }

    it "records the vote without restarting while an active player has not voted" do
      game.vote_play_again!(alice)
      game.reload
      expect(game).to be_ended
      expect(game.start_voters).to eq([alice.id])
    end

    it "ignores a repeat vote" do
      game.vote_play_again!(alice)
      game.vote_play_again!(alice)
      expect(game.reload.start_voters).to eq([alice.id])
    end

    it "restarts once every active player has voted" do
      game.vote_play_again!(alice)
      game.vote_play_again!(bob)
      game.reload
      expect(game).to be_playing
      expect(game.board.size).to eq(12)
      expect(game.deck.size).to eq(69)
      expect(game.start_voters).to be_empty
      expect(game).to be_quick
      expect([alice.reload.score, bob.reload.score]).to eq([0, 0])
    end

    it "does not wait on an inactive player" do
      bob.update!(last_seen_at: 1.minute.ago)
      game.vote_play_again!(alice)
      expect(game.reload).to be_playing
    end

    it "does nothing unless the game is ended" do
      game.update!(status: :playing)
      expect(game.vote_play_again!(alice)).to be_nil
      expect(game.reload.start_voters).to be_empty
    end
  end

  describe "#standings and #winner" do
    let(:game) { Game.create! }
    let!(:alice) { game.players.create!(name: "Alice", color: "#E74C3C", score: 3) }
    let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", score: 7) }

    it "orders players by score, highest first" do
      expect(game.standings).to eq([bob, alice])
    end

    it "names the single top scorer as winner" do
      expect(game.winner).to eq(bob)
    end

    it "has no winner when first place is tied" do
      alice.update!(score: 7)
      expect(game.winner).to be_nil
    end
  end

  describe "#rank_of" do
    let(:game) { Game.create! }
    let!(:alice) { game.players.create!(name: "Alice", color: "#E74C3C", score: 7) }
    let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", score: 7) }
    let!(:caio) { game.players.create!(name: "Caio", color: "#F1C40F", score: 2) }

    it "gives tied players the same rank and skips the next" do
      expect([alice, bob, caio].map { game.rank_of(it) }).to eq([1, 1, 3])
    end
  end

  describe "Game::NO_SET_TIMEOUT" do
    it "is 15 seconds" do
      expect(Game::NO_SET_TIMEOUT).to eq(15)
    end

    it "is the wait call_no_set! schedules ExpireNoSetJob with, not a literal" do
      game = Game.create!.tap(&:start!)
      player = game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current)
      stub_const("Game::NO_SET_TIMEOUT", 20)
      freeze_time do
        expect { game.call_no_set!(player) }
          .to have_enqueued_job(ExpireNoSetJob).with(game).at(Game::NO_SET_TIMEOUT.seconds.from_now)
      end
    end
  end

  describe "refusing a No Set call" do
    let(:game) { Game.create!.tap(&:start!) }
    let!(:alice) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current, score: 2) }
    let!(:bob) { game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current, score: 1) }
    let!(:charlie) { game.players.create!(name: "Charlie", color: "#DC267F", last_seen_at: Time.current) }

    describe "#refuse_no_set!" do
      before { game.call_no_set!(alice) }

      it "cancels the call, records the refuser and returns the game" do
        freeze_time do
          result = game.refuse_no_set!(bob)
          game.reload
          expect(result).to eq(game)
          expect(game.no_set_caller_id).to be_nil
          expect(game.no_set_started_at).to be_nil
          expect(game.no_set_voters).to be_empty
          expect(game.no_set_refuser_id).to eq(bob.id)
          expect(game.no_set_refuser).to eq(bob)
          expect(game.no_set_refused_at).to eq(Time.current)
        end
      end

      it "enqueues UnblockNoSetJob after NO_SET_TIMEOUT" do
        freeze_time do
          expect { game.refuse_no_set!(bob) }
            .to have_enqueued_job(UnblockNoSetJob).with(game).at(Game::NO_SET_TIMEOUT.seconds.from_now)
        end
      end

      it "leaves every score as it was" do
        expect { game.refuse_no_set!(bob) }.not_to(change { game.players.order(:id).pluck(:score) })
      end

      it "accepts a refusal from a locked-out player" do
        bob.update!(locked_until: 10.seconds.from_now)
        expect(game.refuse_no_set!(bob)).to eq(game)
        expect(game.reload.no_set_refuser_id).to eq(bob.id)
      end

      it "returns nil and changes nothing for the caller" do
        expect(game.can_refuse_no_set?(alice)).to be false
        expect(game.refuse_no_set!(alice)).to be_nil
        expect(game.reload.no_set_active?).to be true
        expect(game.no_set_refused_at).to be_nil
      end

      it "returns nil and changes nothing for a player who agreed" do
        game.join_no_set!(bob)
        expect(game.can_refuse_no_set?(bob)).to be false
        expect(game.refuse_no_set!(bob)).to be_nil
        expect(game.reload.no_set_voters).to include(bob.id)
        expect(game.no_set_refused_at).to be_nil
      end

      it "returns nil and enqueues nothing when the player is not allowed" do
        expect { game.refuse_no_set!(alice) }.not_to have_enqueued_job(UnblockNoSetJob)
      end

      it "returns nil for an inactive player" do
        charlie.update_column(:last_seen_at, 1.minute.ago)
        expect(game.can_refuse_no_set?(charlie)).to be false
        expect(game.refuse_no_set!(charlie)).to be_nil
      end

      it "answers can_refuse_no_set? true for an allowed player" do
        expect(game.can_refuse_no_set?(bob)).to be true
      end
    end

    it "returns nil when no call is active" do
      expect(game.can_refuse_no_set?(bob)).to be false
      expect(game.refuse_no_set!(bob)).to be_nil
      expect(game.reload.no_set_refused_at).to be_nil
    end

    it "accepts no second refusal on the same board" do
      game.call_no_set!(alice)
      game.refuse_no_set!(bob)
      travel_to((Game::NO_SET_TIMEOUT + 1).seconds.from_now) do
        expect(game.reload.call_no_set!(alice)).to eq(game)
        expect(game.can_refuse_no_set?(charlie)).to be false
        expect(game.refuse_no_set!(charlie)).to be_nil
        game.reload
        expect(game.no_set_active?).to be true
        expect(game.no_set_refuser_id).to eq(bob.id)
      end
    end

    describe "the block" do
      before do
        game.call_no_set!(alice)
        game.refuse_no_set!(bob)
        game.reload
      end

      it "blocks call_no_set! for everyone, the refuser included" do
        expect(game.no_set_blocked?).to be true
        expect(game.call_no_set!(bob)).to be_nil
        expect(game.call_no_set!(charlie)).to be_nil
        expect(game.reload.no_set_active?).to be false
      end

      it "lifts once NO_SET_TIMEOUT has passed" do
        travel_to(game.no_set_refused_at + (Game::NO_SET_TIMEOUT + 1).seconds) do
          expect(game.no_set_blocked?).to be false
          expect(game.call_no_set!(charlie)).to eq(game)
        end
      end

      it "keeps SET! open" do
        expect(game.try_claim!(charlie)).to be_a(Claim)
      end
    end

    describe "a board change" do
      before do
        game.call_no_set!(alice)
        game.refuse_no_set!(bob)
      end

      def expect_cleared_and_refusable
        game.reload
        expect(game.no_set_refuser_id).to be_nil
        expect(game.no_set_refused_at).to be_nil
        game.call_no_set!(alice)
        expect(game.refuse_no_set!(bob)).to eq(game)
      end

      it "clears the refusal when a No Set call resolves" do
        travel_to((Game::NO_SET_TIMEOUT + 1).seconds.from_now) do
          game.reload.call_no_set!(alice)
          game.resolve_no_set!
          expect_cleared_and_refusable
        end
      end

      it "clears the refusal on start!" do
        game.start!
        expect_cleared_and_refusable
      end

      it "clears the refusal on restart!" do
        game.update!(status: :ended)
        game.restart!
        expect_cleared_and_refusable
      end
    end
  end

  describe "broadcast versions (§7, Screens ignore broadcasts older than what they show)" do
    include ActiveSupport::Testing::Assertions
    include Turbo::Broadcastable::TestHelper

    def version(stream) = stream.to_html[/data-version="(\d+)"/, 1].to_i

    it "stamps the starting vote's board with the game's new updated_at, newer than the earlier vote's" do
      game = Game.create!
      alice = game.players.create!(name: "Alice", color: "#648FFF")
      bob = game.players.create!(name: "Bob", color: "#FE6100")

      first = capture_turbo_stream_broadcasts("game:#{game.code}") { game.vote_start!(alice) }
      second = capture_turbo_stream_broadcasts("game:#{game.code}") { game.vote_start!(bob) }
      expect(game.reload).to be_playing

      first_board = first.reverse.find { |s| s["target"] == "board" }
      second_board = second.reverse.find { |s| s["target"] == "board" }
      expect(version(second_board)).to eq((game.updated_at.to_r * 1_000_000).to_i)
      expect(version(second_board)).to be > version(first_board)
    end
  end
end
