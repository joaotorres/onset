require "rails_helper"

RSpec.describe "Players" do
  let(:game) { Game.create! }
  let(:presets) { PlayersController::PRESET_COLORS }

  def color_radios = Nokogiri::HTML(response.body).css("input[type=radio][name='player[color]']")
  def checked_colors = color_radios.select { |r| r["checked"] }.map { |r| r["value"] }
  def radio_for(hex) = color_radios.find { |r| r["value"] == hex }

  describe "GET /games/:code/players/join" do
    it "returns 200 and shows the join form" do
      get join_game_players_path(game.code)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Joining room")
    end

    it "marks a taken color with the initial of the player who took it" do
      game.players.create!(name: "marta", color: "#1ABC9C")
      get join_game_players_path(game.code)
      expect(response.body).to include('title="Taken by marta"')
      initial = Nokogiri::HTML(response.body).at_css("label[title='Taken by marta'] span")
      expect(initial.text).to eq("M")
      expect(initial["class"]).to include("text-gray-300", "font-display")
    end

    it "selects the first preset color on an empty game" do
      get join_game_players_path(game.code)
      expect(checked_colors).to eq([presets[0]])
    end

    it "selects the first free color when the first two are taken" do
      game.players.create!(name: "a", color: presets[0])
      game.players.create!(name: "b", color: presets[1])
      get join_game_players_path(game.code)
      expect(checked_colors).to eq([presets[2]])
      [presets[0], presets[1]].each do |hex|
        expect(radio_for(hex)["checked"]).to be_nil
        expect(radio_for(hex)["disabled"]).to be_present
      end
    end

    it "says the room is full and disables Join when every color is taken" do
      presets.each_with_index { |hex, i| game.players.create!(name: "p#{i}", color: hex) }
      get join_game_players_path(game.code)
      expect(checked_colors).to be_empty
      doc = Nokogiri::HTML(response.body)
      expect(doc.at_css(".border-red-700")&.text).to include("This room is full")
      submit = doc.at_css("input[type=submit][value=Join]")
      expect(submit["disabled"]).to be_present
    end

    it "keeps Join enabled while a color is free" do
      get join_game_players_path(game.code)
      submit = Nokogiri::HTML(response.body).at_css("input[type=submit][value=Join]")
      expect(submit["disabled"]).to be_nil
      expect(response.body).not_to include("This room is full")
    end

    describe "the big screen link" do
      def big_screen_link = Nokogiri::HTML(response.body).at_css("a:contains('Use this screen as the big screen instead')")

      it "shows to the browser that created the room, linking to its big screen in the same tab" do
        post games_path
        code = Game.last.code
        get join_game_players_path(code)
        expect(big_screen_link["href"]).to eq(game_path(code))
        expect(big_screen_link["target"]).to be_nil
      end

      it "is absent without the host cookie" do
        get join_game_players_path(game.code)
        expect(big_screen_link).to be_nil
      end

      it "is absent with another room's host cookie" do
        post games_path
        get join_game_players_path(game.code)
        expect(big_screen_link).to be_nil
      end
    end
  end

  describe "GET /games/:code/players/new" do
    it "selects the first free color" do
      game.players.create!(name: "a", color: presets[0])
      get new_game_player_path(game.code)
      expect(checked_colors).to eq([presets[1]])
    end
  end

  describe "POST /games/:code/players" do
    let(:valid_params) { {player: {name: "Alice", color: "#E74C3C"}} }

    context "when rate limited" do
      # The test env uses a null cache store, so count in a real one.
      let(:store) { ActiveSupport::Cache::MemoryStore.new }

      before do
        allow(PlayersController.cache_store).to receive(:increment) { |*args, **opts| store.increment(*args, **opts) }
      end

      it "returns 429 after 20 requests a minute" do
        20.times { post game_players_path(game.code), params: {player: {name: "x", color: "#zzz"}} }
        expect(response).not_to have_http_status(:too_many_requests)

        expect { post game_players_path(game.code), params: valid_params }.not_to change(Player, :count)
        expect(response).to have_http_status(:too_many_requests)
        expect(response.body).to include("Try again in a minute.")
        expect(checked_colors).to eq([presets[0]])
      end
    end

    it "does not make the creator the host player" do
      post games_path
      created = Game.last
      post game_players_path(created.code), params: valid_params
      expect(created.players.count).to eq(1)
      expect(created.reload.host_player_id).to be_nil
    end

    it "creates a player and redirects to the controller view" do
      expect { post game_players_path(game.code), params: valid_params }
        .to change(Player, :count).by(1)
      expect(response).to redirect_to(game_controller_path(game.code))
    end

    it "sets the player token cookie" do
      post game_players_path(game.code), params: valid_params
      expect(cookies[:player_token]).to be_present
    end

    it "re-renders the form on invalid params" do
      post game_players_path(game.code), params: {player: {name: "", color: "#E74C3C"}}
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "keeps the posted free color on a name error" do
      post game_players_path(game.code), params: {player: {name: "", color: presets[3]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(checked_colors).to eq([presets[3]])
    end

    it "joins with the preselected color and a name" do
      get join_game_players_path(game.code)
      preselected = checked_colors.first
      post game_players_path(game.code), params: {player: {name: "Zed", color: preselected}}
      expect(response).to redirect_to(game_controller_path(game.code))
      expect(game.players.last.color).to eq(presets[0])
    end

    it "selects the next free color after a clash, wrapping past the last" do
      game.players.create!(name: "a", color: presets[0])
      game.players.create!(name: "h", color: presets[7])
      post game_players_path(game.code), params: {player: {name: "Bob", color: presets[7]}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(checked_colors).to eq([presets[1]])
      expect(radio_for(presets[7])["checked"]).to be_nil
    end

    it "redirects with an alert when the game has already started" do
      game.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: [])
      post game_players_path(game.code), params: valid_params
      expect(response).to redirect_to(join_game_players_path(game.code))
    end

    it "rejects a duplicate color in the same game" do
      Player.create!(name: "Alice", color: "#E74C3C", game: game)
      post game_players_path(game.code), params: {player: {name: "Bob", color: "#E74C3C"}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("has already been taken in this game")
      expect(checked_colors).to eq([presets[1]])
      expect(radio_for("#E74C3C")["checked"]).to be_nil
    end
  end

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

      it "keeps the board read-only during a No Set countdown" do
        game.call_no_set!(bob)
        show
        expect(status.text).to include("No Set called by")
        expect_read_only_board
      end
    end

    context "during a No Set countdown" do
      let(:me) { game.players.find_by!(name: "Alice") }
      let!(:bob) { game.players.create!(name: "Bob", color: "#3498DB", last_seen_at: Time.current) }
      let!(:cat) { game.players.create!(name: "Cat", color: "#2ECC71", last_seen_at: Time.current) }
      let(:doc) { Nokogiri::HTML(response.body) }
      let(:status) { doc.at_css("#controller_status") }
      let(:nodes) { status.css("*").to_a }

      def pos(node) = nodes.index(node)
      def set_button = status.css("button").find { |b| b.text.strip.start_with?("SET!") }
      def agree_button = status.css("button").find { |b| b.text.strip == "I agree, no Set" }
      def text_node(text) = status.css("p").find { |n| n.text.include?(text) }
      def panel = text_node("No Set called by")

      before do
        post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
        game.start!
      end

      def show
        get game_controller_path(game.code)
        expect(response).to have_http_status(:ok)
      end

      it "puts the panel, then SET!, then I agree, no Set for a player who has not agreed" do
        game.call_no_set!(bob)
        show
        expect(panel).to be_present
        expect(pos(panel)).to be < pos(set_button)
        expect(pos(set_button)).to be < pos(agree_button)
      end

      it "makes SET! the round idle button posting to claims" do
        game.call_no_set!(bob)
        show
        expect(set_button["class"]).to include("size-[104px]", "rounded-full")
        form = set_button.ancestors("form").first
        expect(form["action"]).to eq(game_claims_path(game.code))
      end

      it "puts SET! before the caller's waiting text" do
        game.call_no_set!(me)
        show
        waiting = text_node("You called No Set · waiting for")
        expect(pos(set_button)).to be < pos(waiting)
      end

      it "puts SET! before the agreed waiting text" do
        game.call_no_set!(bob)
        game.join_no_set!(me)
        show
        waiting = text_node("You agreed · waiting for")
        expect(pos(set_button)).to be < pos(waiting)
      end

      it "shows a locked-out player the lockout countdown on SET! before the agree pill" do
        me.update!(locked_until: 5.seconds.from_now)
        game.call_no_set!(bob)
        show
        locked = status.at_css("button[aria-label='SET! locked']")
        expect(locked["disabled"]).not_to be_nil
        expect(locked.text).to include("Locked")
        slot = locked.ancestors("[data-set-slot]").first
        expect(slot["data-countdown-started-at-value"]).to eq((me.locked_until - Game::CLAIM_TIMEOUT.seconds).iso8601)
        expect(slot["data-countdown-duration-value"]).to eq(Game::CLAIM_TIMEOUT.to_s)
        expect(slot.at_css(".stroke-red-500")).to be_present
        expect(panel).to be_present
        expect(pos(locked)).to be < pos(agree_button)
      end

      it "no longer shows the Spotted one after all? lead-in" do
        game.call_no_set!(bob)
        show
        expect(response.body).not_to include("Spotted one after all?")
      end
    end

    context "refusing a No Set call" do
      include ActiveSupport::Testing::TimeHelpers

      let(:me) { game.players.find_by!(name: "Alice") }
      let!(:bob) { game.players.create!(name: "Bob", color: "#3498DB", last_seen_at: Time.current) }
      let!(:cat) { game.players.create!(name: "Cat", color: "#2ECC71", last_seen_at: Time.current) }
      let(:doc) { Nokogiri::HTML(response.body) }
      let(:status) { doc.at_css("#controller_status") }
      let(:pill_slot) { status.at_css("[data-pill-slot]") }
      let(:status_slot) { status.at_css("[data-status-slot]") }

      def button(label) = status.css("button").find { |b| b.text.strip == label }
      def refuse_button = button("There's a Set")
      def agree_button = button("I agree, no Set")

      before do
        post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
        game.start!
      end

      def show
        get game_controller_path(game.code)
        expect(response).to have_http_status(:ok)
      end

      describe "during a No Set countdown" do
        it "reads the No Set panel's duration from NO_SET_TIMEOUT" do
          stub_const("Game::NO_SET_TIMEOUT", 20)
          game.call_no_set!(bob)
          show
          panel = status_slot.at_css("[data-controller=countdown]")
          expect(panel["data-countdown-duration-value"]).to eq("20")
          expect(panel.at_css("[data-countdown-target=display]").text.strip).to eq("20")
        end

        it "gives a player who may refuse There's a Set left of I agree, no Set" do
          game.call_no_set!(bob)
          show
          expect(refuse_button).to be_present
          expect(agree_button).to be_present
          expect(refuse_button.ancestors("[data-pill-slot]").first).to eq(pill_slot)
          expect(agree_button.ancestors("[data-pill-slot]").first).to eq(pill_slot)
          nodes = pill_slot.css("*").to_a
          expect(nodes.index(refuse_button)).to be < nodes.index(agree_button)
          expect(refuse_button.ancestors("form").first["action"]).to eq(refuse_game_no_set_path(game.code))
          expect(refuse_button["class"]).to include("border-purple-400", "font-bold", "text-white")
          expect(refuse_button["class"]).not_to match(/(^|\s)bg-purple/)
          expect(agree_button["class"]).to include("bg-purple-700", "text-white")
        end

        it "keeps SET! as it is" do
          game.call_no_set!(bob)
          show
          set = status.css("button").find { |b| b.text.strip == "SET!" }
          expect(set["class"]).to include("size-[104px]", "rounded-full")
          expect(set.ancestors("form").first["action"]).to eq(game_claims_path(game.code))
        end

        it "offers no refusal to the caller" do
          game.call_no_set!(me)
          show
          expect(refuse_button).to be_nil
          expect(status.text).to include("You called No Set · waiting for")
        end

        it "offers no refusal to a player who agreed" do
          game.call_no_set!(bob)
          game.join_no_set!(me)
          show
          expect(refuse_button).to be_nil
          expect(status.text).to include("You agreed · waiting for")
        end

        it "shows the lone I agree, no Set once this board's refusal is used" do
          game.update!(no_set_refuser_id: cat.id, no_set_refused_at: (Game::NO_SET_TIMEOUT + 1).seconds.ago)
          game.call_no_set!(bob)
          show
          expect(refuse_button).to be_nil
          expect(agree_button).to be_present
          expect(agree_button["class"]).to include("portrait:max-lg:w-[220px]")
        end

        it "gives a locked-out player the refusal pair beside the lockout ring" do
          me.update!(locked_until: 5.seconds.from_now)
          game.call_no_set!(bob)
          show
          expect(status_slot.text).to include("No Set called by Bob")
          expect(status.at_css("button[aria-label='SET! locked']")).to be_present
          expect(refuse_button).to be_present
          expect(agree_button).to be_present
        end
      end

      describe "during the block" do
        before do
          game.call_no_set!(bob)
          game.refuse_no_set!(cat)
        end

        def blocked_pill = pill_slot.at_css("button[disabled]")

        it "shows the refused panel with the refuser's dot and name" do
          show
          panel = status_slot.at_css("[role=status]")
          expect(panel["class"]).to include("bg-gray-900", "border-purple-500")
          expect(panel.text.squish).to include("Cat says there's a Set")
          expect(panel.at_css("[style*='#{cat.color}']")).to be_present
          expect(panel.at_css(".font-bold").text.strip).to eq("Cat")
          expect(panel.at_css("[data-countdown-target=ring]")).to be_nil
        end

        it "says You say there's a Set on the refuser's own screen" do
          game.update!(no_set_refuser_id: me.id)
          show
          panel = status_slot.at_css("[role=status]")
          expect(panel.text.squish).to include("You say there's a Set")
          expect(panel.at_css("[style*='#{me.color}']")).to be_present
        end

        it "disables the No Set pill, counting the block down" do
          show
          expect(blocked_pill["class"]).to include("bg-purple-700", "opacity-35", "text-purple-200")
          expect(blocked_pill.text.squish).to match(/\ANo Set in \d+ s\z/)
          expect(blocked_pill["data-controller"]).to eq("countdown")
          expect(blocked_pill["data-countdown-started-at-value"]).to eq(game.reload.no_set_refused_at.iso8601)
          expect(blocked_pill["data-countdown-duration-value"]).to eq(Game::NO_SET_TIMEOUT.to_s)
          expect(blocked_pill.at_css("[data-countdown-target=display]")).to be_present
        end

        it "keeps SET! round, blue and enabled" do
          show
          set = status.css("button").find { |b| b.text.strip == "SET!" }
          expect(set["disabled"]).to be_nil
          expect(set["class"]).to include("bg-blue-600", "rounded-full")
          expect(set.ancestors("form").first["action"]).to eq(game_claims_path(game.code))
        end

        it "shows the End game vote instead of the pill once the deck is empty, the panel staying" do
          game.update!(deck: [])
          show
          expect(pill_slot.text).to include("End game")
          expect(pill_slot.text).not_to include("No Set in")
          expect(status_slot.text.squish).to include("Cat says there's a Set")
        end

        it "shows a locked-out player the refused panel, the lockout ring and the blocked pill" do
          me.update!(locked_until: 5.seconds.from_now)
          show
          expect(status_slot.text.squish).to include("Cat says there's a Set")
          expect(status_slot.text).not_to include("Wrong!")
          expect(status.at_css("button[aria-label='SET! locked']")).to be_present
          expect(blocked_pill.text.squish).to start_with("No Set in")
        end

        it "returns to plain idle with No Set enabled after the block" do
          travel_to((Game::NO_SET_TIMEOUT + 1).seconds.from_now) do
            game.players.update_all(last_seen_at: Time.current)
            show
            expect(status_slot.text.strip).to be_empty
            no_set = button("No Set")
            expect(no_set["disabled"]).to be_nil
            expect(no_set.ancestors("form").first["action"]).to eq(game_no_set_path(game.code))
          end
        end
      end
    end
  end
end
