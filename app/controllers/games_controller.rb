class GamesController < ApplicationController
  def create
    game = Game.create!
    redirect_to game_path(game.code)
  end

  def show
    @game = Game.find_by!(code: params[:code])
    @placeholder_cards = Card.deck.first(12)
  end
end
