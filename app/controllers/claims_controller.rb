class ClaimsController < ApplicationController
  before_action :set_game
  before_action :set_player

  def create
    claim = @game.try_claim!(@player)
    if claim
      redirect_to game_controller_path(@game.code)
    else
      redirect_to game_controller_path(@game.code), status: :conflict
    end
  end

  def update
    claim = @game.claims.find(params[:id])

    unless claim.player_id == @player.id
      head :forbidden and return
    end

    submitted_ids = Array(params[:card_ids]).map(&:to_i)
    claim.submit!(submitted_ids)
    redirect_to game_controller_path(@game.code)
  end

  private

  def set_game
    @game = Game.find_by!(code: params[:game_code])
  end

  def set_player
    token = cookies.encrypted[:player_token]
    @player = @game.players.find_by!(session_token: token)
  end
end
