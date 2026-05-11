class GamesController < ApplicationController
  before_action :set_game, only: [:show, :start, :restart, :ready]

  def create
    game = Game.create!
    cookies.encrypted[:host_game] = {value: game.code, httponly: true, same_site: :lax}
    redirect_to game_path(game.code)
  end

  def show
    @is_host = cookies.encrypted[:host_game] == @game.code
  end

  def start
    unless cookies.encrypted[:host_game] == @game.code
      head :forbidden and return
    end
    @game.start!
    redirect_to game_path(@game.code)
  end

  def restart
    unless cookies.encrypted[:host_game] == @game.code
      head :forbidden and return
    end
    @game.restart!
    redirect_to game_path(@game.code)
  end

  def ready
    player = @game.players.find_by(session_token: cookies.encrypted[:player_token])
    head :forbidden and return unless player

    @game.vote_start!(player)
    head :ok
  end

  private

  def set_game
    @game = Game.find_by!(code: params[:code])
  end
end
