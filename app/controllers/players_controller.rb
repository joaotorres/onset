class PlayersController < ApplicationController
  PRESET_COLORS = %w[#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A].freeze

  before_action :set_game

  def join
    @player = Player.new
    render :new
  end

  def new
    @player = Player.new
  end

  def create
    @player = @game.players.build(player_params)
    if @player.save
      cookies.encrypted[:player_token] = {value: @player.session_token, httponly: true, same_site: :lax}
      redirect_to game_controller_path(@game.code)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find_by!(code: params[:game_code])
  end

  def player_params
    params.expect(player: [:name, :color])
  end
end
