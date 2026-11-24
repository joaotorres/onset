require "rails_helper"

# SPEC.md, AI opponent > Adding a bot; §2 Edge cases (the bot bullet); §4 `Player`.
RSpec.describe "Bots" do
  let(:game) { Game.create! }
  let(:presets) { Player::PRESET_COLORS }

  def person(name, color, **attrs) = game.players.create!(name: name, color: color, last_seen_at: Time.current, **attrs)

  describe "Player" do
    it "is a bot when it has a level, a person otherwise" do
      expect(game.add_bot!("easy")).to be_bot
      expect(person("Alice", presets.last)).not_to be_bot
    end

    it "is never active as a bot, even when seen a moment ago" do
      bot = game.add_bot!("hard")
      bot.update_column(:last_seen_at, Time.current)
      expect(bot.reload).not_to be_active
    end

    it "gives a bot a random session token like any player" do
      tokens = [game.add_bot!("easy"), game.add_bot!("easy")].map(&:session_token)
      expect(tokens).to all(match(/\A\h{32}\z/))
      expect(tokens.uniq.size).to eq(2)
    end
  end

  describe "Game#add_bot!" do
    it "adds a bot named after its level on the first free preset color" do
      person("Alice", presets[0])
      person("Bob", presets[2])
      bot = game.add_bot!("easy")
      expect(bot).to have_attributes(name: "Easy bot", bot_level: "easy", color: presets[1], score: 0)
    end

    it "numbers a second bot of the same level, each level apart" do
      names = %w[easy easy medium easy hard].map { |level| game.add_bot!(level).name }
      expect(names).to eq(["Easy bot", "Easy bot 2", "Medium bot", "Easy bot 3", "Hard bot"])
    end

    it "skips a name a person holds, whatever its case" do
      person("easy bot", presets[0])
      expect(game.add_bot!("easy").name).to eq("Easy bot 2")
    end

    it "takes the lowest free name again once it is free" do
      first = game.add_bot!("easy")
      game.add_bot!("easy")
      first.destroy!
      expect(game.add_bot!("easy").name).to eq("Easy bot")
    end

    it "adds nothing for a level that is not one of the three" do
      [nil, "", "expert", "0", "EASY"].each { |level| expect(game.add_bot!(level)).to be_nil }
      expect(game.players.count).to eq(0)
    end

    it "adds nothing once every color is taken" do
      presets.each_with_index { |color, i| person("Player #{i}", color) }
      expect(game.add_bot!("easy")).to be_nil
      expect(game.players.count).to eq(8)
    end

    it "adds nothing once the room is playing or ended" do
      person("Alice", presets[0])
      person("Bob", presets[1])
      game.start!
      expect(game.add_bot!("easy")).to be_nil
      game.update!(status: :ended)
      expect(game.add_bot!("easy")).to be_nil
      expect(game.players.count).to eq(2)
    end

    it "adds nothing when it loses the race for a color or a name at the index" do
      allow_any_instance_of(Player).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique)
      expect(game.add_bot!("easy")).to be_nil
      expect(game.players.count).to eq(0)
    end

    it "broadcasts as a join does" do
      expect_any_instance_of(Game).to receive(:broadcast_lobby_state)
      game.add_bot!("easy")
    end
  end

  describe "the ready vote" do
    it "counts a bot as ready from the moment it joins" do
      bot = game.add_bot!("easy")
      alice = person("Alice", presets[1])
      expect(game.ready?(bot)).to be(true)
      expect(game.ready?(alice)).to be(false)
      expect(game.ready_count).to eq(1)
    end

    it "starts a room of one person and one bot once the person votes" do
      game.add_bot!("easy")
      game.vote_start!(person("Alice", presets[1]))
      expect(game.reload).to be_playing
    end

    it "waits for every person in a room of two people and a bot" do
      alice = person("Alice", presets[0])
      bob = person("Bob", presets[1])
      game.add_bot!("medium")

      game.vote_start!(alice)
      expect(game.reload).to be_waiting
      expect(game.ready_waiting_count).to eq(1)

      game.vote_start!(bob)
      expect(game.reload).to be_playing
    end

    it "is startable only with 2 or more players, at least one a person" do
      game.add_bot!("easy")
      expect(game).not_to be_startable
      game.add_bot!("hard")
      expect(game.reload).not_to be_startable
      person("Alice", presets[2])
      expect(game.reload).to be_startable
    end
  end

  describe "votes in play" do
    let!(:alice) { person("Alice", presets[0]) }
    let!(:bot) { game.add_bot!("easy") }

    before { game.start! }

    it "resolves a No Set call when the other person agrees, the bot never holding it up" do
      bob = person("Bob", presets[2])
      game.call_no_set!(alice)
      expect(game.reload).to be_no_set_active
      game.join_no_set!(bob)
      expect(game.reload).not_to be_no_set_active
      expect(game.board.size).to eq(15)
    end

    it "never counts the bot among those a No Set call waits for or who may refuse" do
      game.call_no_set!(alice)
      expect(game.reload.no_set_voters).to eq([alice.id])
      expect(game.can_refuse_no_set?(bot)).to be(false)
      expect(game.players.select(&:active?)).to eq([alice])
    end

    it "ends on the people's End game votes alone" do
      game.update!(deck: [])
      game.vote_end_game!(alice)
      expect(game.reload).to be_ended
    end

    it "restarts on the people's Play again votes alone, the bots kept at score 0" do
      bot.update!(score: 4)
      game.update!(status: :ended)
      game.vote_play_again!(alice)
      expect(game.reload).to be_playing
      expect(game.players.where.not(bot_level: nil).pluck(:name, :score)).to eq([["Easy bot", 0]])
    end

    it "keeps the bots through the big screen's Play again" do
      bot.update!(score: 4)
      game.update!(status: :ended)
      game.restart!
      expect(bot.reload).to have_attributes(score: 0, bot_level: "easy")
    end
  end
end
