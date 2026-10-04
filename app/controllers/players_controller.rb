class PlayersController < ApplicationController
  PRESET_COLORS = %w[#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A].freeze

  before_action :set_game
  before_action :set_color_owners, only: [:new, :join, :create]
  rate_limit to: 20, within: 1.minute, only: :create, with: -> {
    @player = Player.new
    flash.now[:alert] = "Too many join attempts. Try again in a minute."
    render :new, status: :too_many_requests
  }

  def join
    @player = Player.new
    render :new
  end

  def new
    @player = Player.new
  end

  def create
    unless @game.waiting?
      redirect_to join_game_players_path(@game.code), alert: "This game has already started." and return
    end

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

  def set_color_owners
    @color_owners = @game.players.index_by(&:color)
  end

  def player_params
    params.expect(player: [:name, :color])
  end
end
