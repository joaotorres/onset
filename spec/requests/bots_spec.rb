require "rails_helper"

# SPEC.md, AI opponent > Adding a bot; §5 Routes (`POST /games/:code/bots`).
RSpec.describe "Bots" do
  let(:presets) { Player::PRESET_COLORS }

  def html = Nokogiri::HTML(response.body)

  # The browser that created the room holds its host_game cookie.
  def host_room
    post games_path
    Game.last
  end

  describe "POST /games/:code/bots" do
    context "as the host" do
      let!(:game) { host_room }

      it "adds an Easy bot, already ready, and answers 204" do
        post game_bots_path(game.code), params: {level: "easy"}
        expect(response).to have_http_status(:no_content)
        bot = game.players.sole
        expect(bot).to have_attributes(name: "Easy bot", bot_level: "easy", color: presets.first)
        expect(bot.session_token).to match(/\A\h{32}\z/)
        expect(game.reload.ready?(bot)).to be(true)
      end

      it "numbers the second Easy bot, and skips a name a person holds" do
        2.times { post game_bots_path(game.code), params: {level: "easy"} }
        expect(game.players.order(:id).pluck(:name)).to eq(["Easy bot", "Easy bot 2"])

        other = host_room
        other.players.create!(name: "easy bot", color: presets.last)
        post game_bots_path(other.code), params: {level: "easy"}
        expect(other.players.order(:id).last.name).to eq("Easy bot 2")
      end

      it "sets no player cookie" do
        post game_bots_path(game.code), params: {level: "hard"}
        expect(cookies[:player_token]).to be_blank
      end

      it "ignores the add while playing or ended, still 204" do
        game.players.create!(name: "Alice", color: presets[0])
        game.players.create!(name: "Bob", color: presets[1])
        game.start!
        post game_bots_path(game.code), params: {level: "easy"}
        expect(response).to have_http_status(:no_content)

        game.update!(status: :ended)
        post game_bots_path(game.code), params: {level: "easy"}
        expect(response).to have_http_status(:no_content)
        expect(game.players.count).to eq(2)
      end

      it "ignores any level but the three, still 204" do
        [{}, {level: ""}, {level: "expert"}, {level: "2"}, {level: ["easy"]}, {level: {easy: "1"}}].each do |params|
          post game_bots_path(game.code), params: params
          expect(response).to have_http_status(:no_content)
        end
        expect(game.players.count).to eq(0)
      end

      it "ignores the add when all 8 colors are taken, still 204" do
        presets.each_with_index { |color, i| game.players.create!(name: "Player #{i}", color: color) }
        post game_bots_path(game.code), params: {level: "easy"}
        expect(response).to have_http_status(:no_content)
        expect(game.players.count).to eq(8)
      end

      it "answers 204 and adds nothing when the add loses the race for a color" do
        allow_any_instance_of(Player).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique)
        post game_bots_path(game.code), params: {level: "easy"}
        expect(response).to have_http_status(:no_content)
        expect(game.players.count).to eq(0)
      end
    end

    it "answers 403 and adds nothing without the host cookie" do
      game = Game.create!
      post game_bots_path(game.code), params: {level: "easy"}
      expect(response).to have_http_status(:forbidden)
      expect(game.players.count).to eq(0)
    end

    it "answers 403 and adds nothing with another room's host cookie" do
      game = Game.create!
      host_room
      post game_bots_path(game.code), params: {level: "easy"}
      expect(response).to have_http_status(:forbidden)
      expect(game.players.count).to eq(0)
    end

    it "answers 404 for a room that does not exist" do
      post game_bots_path("ZZZZZZ"), params: {level: "easy"}
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "a request with no player cookie" do
    let(:game) { Game.create! }

    before { game.add_bot!("easy") }

    it "never resolves to a bot on the player screen" do
      get game_controller_path(game.code)
      expect(response).to have_http_status(:not_found)
    end

    it "never votes or claims as a bot" do
      post ready_game_path(game.code)
      expect(response).to have_http_status(:forbidden)
      game.players.create!(name: "Alice", color: presets.last)
      game.start!
      post game_claims_path(game.code)
      expect(response).to have_http_status(:not_found)
      expect(game.reload.claim_player_id).to be_nil
    end
  end

  describe "starting with bots" do
    let!(:game) { host_room }

    it "ignores POST /start, still 204, while every player is a bot" do
      2.times { game.add_bot!("easy") }
      post start_game_path(game.code)
      expect(response).to have_http_status(:no_content)
      expect(game.reload).to be_waiting
    end

    it "starts from POST /start with one person and one bot" do
      game.add_bot!("easy")
      game.players.create!(name: "Alice", color: presets.last)
      post start_game_path(game.code)
      expect(game.reload).to be_playing
    end

    it "starts by the ready vote once the one person votes, with a bot in the room" do
      game.add_bot!("easy")
      post game_players_path(game.code), params: {player: {name: "Alice", color: presets.last}}
      post ready_game_path(game.code)
      expect(game.reload).to be_playing
    end
  end

  describe "the big screen while waiting" do
    let(:game) { Game.create! }

    def big_screen
      get game_path(game.code)
      html
    end

    it "shows the add-bot tile to every viewer, with its accessible names" do
      tile = big_screen.at_css("#room_tile [role=group][aria-label='Add a bot']")
      expect(tile.text).to include("Add a bot")
      buttons = tile.css("form[action='#{game_bots_path(game.code)}'] button")
      expect(buttons.map { |b| b["aria-label"] }).to eq(["Add Easy bot", "Add Medium bot", "Add Hard bot"])
      expect(buttons.map { |b| b.text.strip }).to eq(%w[Easy Medium Hard])
      expect(tile.css("form input[name=level]").map { |i| i["value"] }).to eq(%w[easy medium hard])
      expect(buttons.map { |b| b["disabled"] }).to all(be_nil)
      expect(tile.text).not_to include("Room full")
    end

    it "sends bot_added with the level on a tap" do
      buttons = big_screen.css("#room_tile [data-controller='add-bot'] button")
      expect(buttons.map { |b| b["data-action"] }).to all(eq("click->add-bot#track"))
      expect(buttons.map { |b| b["data-add-bot-level-param"] }).to eq(%w[easy medium hard])
    end

    it "disables the three buttons with Room full at 8 players" do
      presets.each_with_index { |color, i| game.players.create!(name: "Player #{i}", color: color) }
      tile = big_screen.at_css("#room_tile [role=group]")
      reason = tile.css("p").find { |p| p.text.strip == "Room full" }
      buttons = tile.css("button")
      expect(buttons.size).to eq(3)
      expect(buttons.map { |b| b["disabled"] }).to all(be_present)
      expect(buttons.map { |b| b["aria-describedby"] }).to all(eq(reason["id"]))
    end

    it "stamps the tile's root with the room's players' version, so a join updates it" do
      game.players.create!(name: "Alice", color: presets.first)
      doc = big_screen
      expect(doc.at_css("#room_tile")["data-version"]).to eq(doc.at_css("#board")["data-version"])
    end

    it "hides the tile once play starts" do
      game.players.create!(name: "Alice", color: presets[0])
      game.add_bot!("easy")
      game.start!
      doc = big_screen
      expect(doc.at_css("[aria-label='Add a bot']")).to be_nil
      expect(doc.at_css("#room_tile").text).to include(game.code)
    end

    it "puts the bot mark after a bot's name on its pill, before the ✓" do
      game.players.create!(name: "Alice", color: presets[0])
      game.add_bot!("easy")
      pills = big_screen.css("#board li")
      bot = pills.find { |li| li.text.include?("Easy bot") }
      mark = bot.at_css("svg[role=img][aria-label=bot]")
      expect(mark).to be_present
      expect(bot.text).to include("✓")
      expect(bot.inner_html.index("Easy bot")).to be < bot.inner_html.index("<svg")
      expect(bot.inner_html.index("<svg")).to be < bot.inner_html.index("✓")

      alice = pills.find { |li| li.text.include?("Alice") }
      expect(alice.at_css("svg")).to be_nil
      expect(alice.text).not_to include("✓")
    end

    it "counts the bots as ready beside Start game" do
      game.players.create!(name: "Alice", color: presets[0])
      game.add_bot!("easy")
      start = big_screen.at_css("#start_button")
      expect(start.text.squish).to include("1 of 2 ready")
      expect(start.at_css("form[action='#{start_game_path(game.code)}'] button")).to be_present
    end

    it "disables Start game with Need a person to play while every player is a bot" do
      2.times { game.add_bot!("hard") }
      start = big_screen.at_css("#start_button")
      button = start.at_css("button")
      expect(button["disabled"]).to be_present
      expect(start.at_css("form")).to be_nil
      reason = start.at_css("##{button["aria-describedby"]}")
      expect(reason.text.strip).to eq("Need a person to play")
    end

    it "still reads Need at least 2 players with one bot alone" do
      game.add_bot!("easy")
      expect(big_screen.at_css("#start_button").text).to include("Need at least 2 players")
    end
  end

  describe "the player screen while waiting" do
    let(:game) { Game.create! }

    def status
      get game_controller_path(game.code)
      html.at_css("#controller_status")
    end

    before { post game_players_path(game.code), params: {player: {name: "Alice", color: presets.last}} }

    it "shows a bot in the roster with its mark and ✓, and no add-bot control" do
      game.add_bot!("medium")
      s = status
      row = s.css("[data-roster] li").find { |li| li.text.include?("Medium bot") }
      expect(row.at_css("svg[role=img][aria-label=bot]")).to be_present
      expect(row.at_css("[aria-label=ready]")).to be_present
      expect(row.inner_html.index("<svg")).to be < row.inner_html.index("✓")
      own = s.css("[data-roster] li").find { |li| li.text.include?("Alice") }
      expect(own.at_css("svg")).to be_nil
      expect(s.at_css("[aria-label='Add a bot']")).to be_nil
      expect(s.at_css("form[action='#{game_bots_path(game.code)}']")).to be_nil
    end

    it "lets a person with a bot vote" do
      expect(status.text).to include("Waiting for more players to join…")
      game.add_bot!("easy")
      expect(status.at_css("form[action='#{ready_game_path(game.code)}'] button").text).to include("I'm ready")
    end

    it "counts people only in the voted line" do
      game.add_bot!("easy")
      game.players.create!(name: "Bob", color: presets[1])
      post ready_game_path(game.code)
      expect(game.reload).to be_waiting
      expect(status.text).to include("Ready ✓ · waiting for 1 more")
    end
  end
end
