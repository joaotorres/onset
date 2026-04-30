class GamesController < ApplicationController
  before_action :set_game, only: [:show, :start]

  def create
    game = Game.create!
    cookies.encrypted[:host_game] = {value: game.code, httponly: true, same_site: :lax}
    redirect_to game_path(game.code)
  end

  def show
    @is_host = cookies.encrypted[:host_game] == @game.code
    @board_cards = @game.board.present? ? @game.board_cards : Card.deck.first(12)
  end

  def start
    unless cookies.encrypted[:host_game] == @game.code
      head :forbidden and return
    end
    @game.start!
    redirect_to game_path(@game.code)
  end

  private

  def set_game
    @game = Game.find_by!(code: params[:code])
  end
end
