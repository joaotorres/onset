require "rails_helper"

RSpec.describe Game do
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
      player.update!(locked_until: 5.seconds.from_now)
      expect(game.try_claim!(player)).to be_nil
    end

    it "cancels an active No-Set when a claim is acquired" do
      game.update!(no_set_caller_id: player.id, no_set_started_at: Time.current, no_set_voters: [player.id])
      game.try_claim!(player)
      expect(game.reload.no_set_active?).to be false
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
end
