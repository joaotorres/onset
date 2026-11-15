require "rails_helper"

# SPEC §10 Themes and §7 Hooks: a broadcast partial renders the same for every
# player, so #controller_status never depends on the viewer's theme cookie.
RSpec.describe "Player screen and the theme cookie" do
  include_context "players"

  let(:me) { game.players.find_by!(name: "Alice") }
  let!(:bob) { game.players.create!(name: "Bob", color: "#3498DB", last_seen_at: Time.current) }

  before { post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}} }

  def status_with(theme)
    theme ? cookies[:theme] = theme : cookies.delete(:theme)
    get game_controller_path(game.code)
    expect(response).to have_http_status(:ok)
    status = Nokogiri::HTML(response.body).at_css("#controller_status")
    # Each request has its own CSRF token and card pattern ids; nothing else may differ.
    status.css('input[name="authenticity_token"]').each(&:remove)
    status.to_html.gsub(/(stripes-\w+)-\h{8}/, '\1')
  end

  {
    "waiting" => -> {},
    "idle" => -> { game.start! },
    "someone else claiming" => -> {
      game.start!
      game.try_claim!(bob)
    },
    "No Set blocked" => -> {
      game.start!
      game.call_no_set!(bob)
      game.refuse_no_set!(me)
    },
    "game over" => -> { game.update!(status: :ended) }
  }.each do |name, setup|
    it "renders #controller_status the same with theme=light, theme=dark and none while #{name}" do
      instance_exec(&setup)
      none = status_with(nil)
      expect(status_with("light")).to eq(none)
      expect(status_with("dark")).to eq(none)
    end
  end

  it "renders the settings button outside #controller_status" do
    get game_controller_path(game.code)
    doc = Nokogiri::HTML(response.body)
    expect(doc.css('main button[aria-label="Settings"]').size).to eq(1)
    expect(doc.css('#controller_status button[aria-label="Settings"]')).to be_empty
  end
end
