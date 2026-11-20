# Shared by the spec files in spec/requests/players/.
RSpec.shared_context "players" do
  let(:game) { Game.create! }
  let(:presets) { Player::PRESET_COLORS }

  def color_radios = Nokogiri::HTML(response.body).css("input[type=radio][name='player[color]']")
  def checked_colors = color_radios.select { |r| r["checked"] }.map { |r| r["value"] }
  def radio_for(hex) = color_radios.find { |r| r["value"] == hex }
end
