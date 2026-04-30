class ControllersController < ApplicationController
  def show
    @game = Game.find_by!(code: params[:game_code])
    token = cookies.encrypted[:player_token]
    @player = @game.players.find_by!(session_token: token)
    @my_claim = @game.claims.find_by(player: @player, result: :pending) if @game.claim_player_id == @player.id
  end
end
