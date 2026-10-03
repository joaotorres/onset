class GamesController < ApplicationController
  before_action :set_game, only: [:show, :start, :restart, :ready]

  def create
    game = Game.create!(mode: (params[:mode] == "quick") ? :quick : :standard)
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
    @game.start! if @game.players.count >= 2
    head :no_content
  end

  def restart
    unless cookies.encrypted[:host_game] == @game.code
      head :forbidden and return
    end
    @game.restart!
    head :no_content
  end

  def ready
    player = @game.players.find_by(session_token: cookies.encrypted[:player_token])
    head :forbidden and return unless player

    @game.vote_start!(player)
    head :no_content
  end

  private

  def set_game
    @game = Game.find_by!(code: params[:code])
  end
end
