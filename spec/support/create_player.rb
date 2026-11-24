# A player in `game` with the room's first free preset, in PRESET_COLORS order
# as the join page picks (§8), for builds where the color is not the point.
# Passed attributes win. With no preset free, the model's validations raise.
module CreatePlayer
  def create_player(game, **attrs)
    taken = game.players.pluck(:color)
    defaults = {
      name: "Player #{game.players.count + 1}",
      color: Player::PRESET_COLORS.find { |hex| !taken.include?(hex) }
    }
    game.players.create!(defaults.merge(attrs))
  end
end

RSpec.configure { |config| config.include CreatePlayer }
