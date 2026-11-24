# The host's bot controls (SPEC, AI opponent). The host is the browser holding
# the room's host_game cookie, checked on every action as Start game checks it.
class BotsController < ApplicationController
  def create
    game = Game.find_by!(code: params[:game_code])
    head :forbidden and return unless cookies.encrypted[:host_game] == game.code

    # Ignored, still 204, unless the room is waiting, the level is one of the three and a color is free.
    game.add_bot!(params[:level])
    head :no_content
  end
end
