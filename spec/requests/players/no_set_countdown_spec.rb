require "rails_helper"

RSpec.describe "Players" do
  include_context "players"

  describe "GET /games/:code/controller" do
    context "during a No Set countdown" do
      let(:me) { game.players.find_by!(name: "Alice") }
      let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current) }
      let!(:cat) { game.players.create!(name: "Cat", color: "#F1C40F", last_seen_at: Time.current) }
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
  end
end
