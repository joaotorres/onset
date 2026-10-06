class LobbiesController < ApplicationController
  def new
  end

  def join
    game = Game.find_by(code: params[:code].to_s.strip.upcase)
    return redirect_to(root_path, alert: "Room not found. Check the code on the big screen.") unless game

    redirect_to join_game_players_path(game.code)
  end

  def how_to_play
    return_to = params[:return_to].to_s
    # only same-site paths, never a full URL or protocol-relative //host
    @return_to = return_to if return_to.start_with?("/") && !return_to.start_with?("//")
    @back_path = @return_to || root_path
  end
end
