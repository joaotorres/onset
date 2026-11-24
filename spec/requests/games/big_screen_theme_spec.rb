require "rails_helper"

# SPEC §10 Themes and §7 Hooks: the big screen's broadcast partials render the
# same for every viewer, so none depends on the viewer's theme cookie, and the
# settings button sits outside all of them.
RSpec.describe "Big screen and the theme cookie" do
  let(:game) { Game.create! }
  let!(:alice) { create_player(game, name: "Alice", last_seen_at: Time.current) }
  let!(:bob) { create_player(game, name: "Bob", last_seen_at: Time.current) }

  def targets = %w[#board #scoreboard #announcement #start_button #room_tile]

  def targets_with(theme)
    theme ? cookies[:theme] = theme : cookies.delete(:theme)
    get game_path(game.code)
    expect(response).to have_http_status(:ok)
    doc = Nokogiri::HTML(response.body)
    doc.css('input[name="authenticity_token"]').each(&:remove)
    # Card pattern ids are unique per render; nothing else may differ. #start_button renders only while waiting.
    targets.map { |id| doc.at_css(id)&.to_html&.gsub(/(stripes-\w+)-\h{8}/, '\1') }
  end

  def flash!(result)
    game.start!
    claim = game.claims.create!(player: bob, result: result, card_ids: game.board.first(3), started_at: Time.current, resolved_at: Time.current)
    game.update!(flash_claim_id: claim.id)
  end

  {
    "waiting with one player" => -> { bob.destroy },
    "waiting" => -> {},
    "idle with a locked player" => -> {
      game.start!
      alice.update!(locked_until: 10.seconds.from_now)
    },
    "claiming" => -> {
      game.start!
      game.try_claim!(bob)
    },
    "No Set" => -> {
      game.start!
      game.call_no_set!(bob)
    },
    "refused" => -> {
      game.start!
      game.call_no_set!(bob)
      game.refuse_no_set!(alice)
    },
    "correct" => -> { flash!(:correct) },
    "wrong" => -> { flash!(:wrong) },
    "deck empty" => -> {
      game.start!
      game.update!(deck: [])
    },
    "ended" => -> {
      alice.update!(score: 3)
      game.update!(status: :ended)
    }
  }.each do |name, setup|
    it "renders every broadcast target the same with theme=light, theme=dark and none while #{name}" do
      instance_exec(&setup)
      none = targets_with(nil)
      expect(targets_with("light")).to eq(none)
      expect(targets_with("dark")).to eq(none)
    end
  end

  it "renders the settings button outside every broadcast target" do
    get game_path(game.code)
    doc = Nokogiri::HTML(response.body)
    expect(doc.css('main button[aria-label="Settings"]').size).to eq(1)
    targets.each { |id| expect(doc.css(%(#{id} button[aria-label="Settings"]))).to be_empty }
  end
end
