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

    raw = params[:card_ids]
    submitted_ids = if raw.is_a?(String)
      begin
        JSON.parse(raw).map(&:to_i)
      rescue
        []
      end
    else
      Array(raw).map(&:to_i)
    end
    claim.submit!(submitted_ids)
    head :no_content
  end

  private

  def set_game
    @game = Game.find_by!(code: params[:game_code])
  end

  def set_player
    token = cookies.encrypted[:player_token]
    @player = @game.players.find_by!(session_token: token)
    @player.seen!
  end
end
