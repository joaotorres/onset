class LobbiesController < ApplicationController
  def new
  end

  def join
    game = Game.find_by(code: params[:code].to_s.strip.upcase)
    return redirect_to(root_path, alert: "Room not found") unless game

    redirect_to join_game_players_path(game.code)
  end

  def how_to_play
    # only a game code, so the Back link can never point off the site
    code = params[:game].to_s
    @player_screen_path = game_controller_path(code) if code.match?(Game::CODE_FORMAT)
    @back_path = @player_screen_path || root_path
  end
end
