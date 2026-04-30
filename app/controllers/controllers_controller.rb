class ControllersController < ApplicationController
  def show
    @game = Game.find_by!(code: params[:game_code])
    token = cookies.encrypted[:player_token]
    @player = @game.players.find_by!(session_token: token)
  end
end
