class PlayersController < ApplicationController
  PRESET_COLORS = %w[#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A].freeze

  before_action :set_game
  before_action :set_color_owners, only: [:new, :join, :create]
  helper_method :creator?, :full?
  rate_limit to: 20, within: 1.minute, only: :create, with: -> {
    @player = Player.new(color: first_free_color)
    flash.now[:alert] = "Too many join attempts. Try again in a minute."
    render :new, status: :too_many_requests
  }

  def join
    @player = Player.new(color: first_free_color)
    render :new
  end

  def new
    @player = Player.new(color: first_free_color)
  end

  def create
    unless @game.waiting?
      redirect_to join_game_players_path(@game.code), alert: "This game has already started." and return
    end

    @player = @game.players.build(player_params)
    if @player.save
      cookies.encrypted[:player_token] = {value: @player.session_token, httponly: true, same_site: :lax}
      track_event("player_joined", player_count: @game.players.count, is_creator: creator?, mode: @game.mode)
      redirect_to game_controller_path(@game.code)
    else
      @player.color = color_for_rerender(@player.color)
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

  def creator? = cookies.encrypted[:host_game] == @game.code

  def full? = first_free_color.nil?

  def free?(hex) = PRESET_COLORS.include?(hex) && !@color_owners.key?(hex)

  def first_free_color = PRESET_COLORS.find { |hex| free?(hex) }

  # A clashed color moves to the next free preset after it, wrapping; a free
  # choice is kept; anything else falls back to the first free color.
  def color_for_rerender(posted)
    return posted if free?(posted)

    index = PRESET_COLORS.index(posted)
    return first_free_color unless index

    PRESET_COLORS.rotate(index + 1).find { |hex| free?(hex) }
  end

  def player_params
    params.expect(player: [:name, :color])
  end
end
