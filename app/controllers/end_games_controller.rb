class EndGamesController < ApplicationController
  before_action :set_game
  before_action :set_player

  def create
    @game.vote_end_game!(@player)
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
