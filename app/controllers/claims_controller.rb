class ClaimsController < ApplicationController
  before_action :set_game
  before_action :set_player

  def create
    # A lost race is not an error: the broadcast shows who is claiming.
    @game.try_claim!(@player)
    head :no_content
  end

  def update
    claim = @game.claims.find(params[:id])

    unless claim.player_id == @player.id
      head :forbidden and return
    end

    # Stores the picks; nothing is judged until the time runs out (§11).
    claim.pick!(picked_ids)
    head :no_content
  end

  private

  # The player screen sends a JSON array; a JSON string is accepted too.
  # Anything else becomes an invalid selection, which pick! ignores.
  def picked_ids
    raw = params[:card_ids]
    raw = JSON.parse(raw) if raw.is_a?(String)
    Array(raw).map { |id| Integer(id) }
  rescue JSON::ParserError, ArgumentError, TypeError
    nil
  end

  def set_game
    @game = Game.find_by!(code: params[:game_code])
  end

  def set_player
    token = cookies.encrypted[:player_token]
    @player = @game.players.find_by!(session_token: token)
    @player.seen!
  end
end
