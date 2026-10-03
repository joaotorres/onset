class LobbiesController < ApplicationController
  def new
  end

  def join
    game = Game.find_by(code: params[:code].to_s.strip.upcase)
    return redirect_to(root_path, alert: "Room not found. Check the code on the big screen.") unless game

    redirect_to join_game_players_path(game.code)
  end
end
