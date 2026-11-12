# Shared by spec/requests/games/playing*_spec.rb: the player screen during play, as HTML.
RSpec.shared_context "games while playing" do
  let(:game) { Game.create! }

  def sign_in_player(name: "Alice", color: "#E74C3C")
    post game_players_path(game.code), params: {player: {name: name, color: color}}
    game.players.find_by!(name: name)
  end

  let!(:alice) { sign_in_player }
  let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current) }
  let!(:cleo) { game.players.create!(name: "Cleo", color: "#F1C40F", last_seen_at: Time.current) }

  before { game.start! }

  def status
    get game_controller_path(game.code)
    Nokogiri::HTML(response.body).at_css("#controller_status")
  end

  def entries(s) = s.css("[data-scoreboard] li")
  def entry(s, name) = entries(s).find { |li| li.at_css("[data-name]").text.strip == name }
  def buttons(s, text) = s.css("button").select { |b| b.text.strip.start_with?(text) }
end
