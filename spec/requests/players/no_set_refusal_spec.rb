require "rails_helper"

RSpec.describe "Players" do
  include_context "players"

  describe "GET /games/:code/controller" do
    context "refusing a No Set call" do
      include ActiveSupport::Testing::TimeHelpers

      let(:me) { game.players.find_by!(name: "Alice") }
      let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current) }
      let!(:cat) { game.players.create!(name: "Cat", color: "#F1C40F", last_seen_at: Time.current) }
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
          # DESIGN v6: the fill at 35%, the label at full strength, never the whole pill faded.
          expect(blocked_pill["class"]).to include("bg-purple-700/35", "text-purple-200")
          expect(blocked_pill["class"]).not_to include("opacity-35")
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
