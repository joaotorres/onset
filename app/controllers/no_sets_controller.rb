class NoSetsController < ApplicationController
  before_action :set_game
  before_action :set_player

  def create
    if @game.no_set_active?
      @game.join_no_set!(@player)
    else
      @game.call_no_set!(@player)
    end
    head :no_content
  end

  # Once per board, and not by the caller or a player who agreed (§2); anything else is ignored.
  def refuse
    @game.refuse_no_set!(@player)
    head :no_content
  end

  def destroy
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
