class ClaimsController < ApplicationController
  before_action :stamp_arrival, only: :create
  before_action :set_game
  before_action :set_player

  def create
    # A lost race is not an error: the broadcast shows who is claiming.
    @game.try_claim!(@player, arrived_at: @arrived_at)
    head :no_content
  end

  def update
    # Stores the picks; nothing is judged until Submit or the time runs out (§11).
    held_claim&.pick!(picked_ids)
    head(held_claim ? :no_content : :forbidden)
  end

  def submit
    # Judges the selection the request carries at once (§11).
    held_claim&.submit!(picked_ids)
    head(held_claim ? :no_content : :forbidden)
  end

  private

  # Before the lookups and the lock, so a wait for them does not inflate the near-tie gap (§6).
  def stamp_arrival
    @arrived_at = Time.current
  end

  # The claim in the URL, or nil when this player does not hold it.
  def held_claim
    return @held_claim if defined?(@held_claim)

    claim = @game.claims.find(params[:id])
    @held_claim = (claim.player_id == @player.id) ? claim : nil
  end

  # The player screen sends a JSON array; a JSON string is accepted too.
  # Anything else becomes an invalid selection, which pick! ignores.
  def picked_ids
    raw = params[:card_ids]
    raw = JSON.parse(raw) if raw.is_a?(String)
    Array(raw).map { |id| Integer(id) }
  rescue JSON::ParserError, ArgumentError, TypeError
    nil
  end

  def set_game
    @game = Game.find_by!(code: params[:game_code])
  end

  def set_player
    token = cookies.encrypted[:player_token]
    @player = @game.players.find_by!(session_token: token)
    @player.seen!
  end
end
