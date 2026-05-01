class Game < ApplicationRecord
  CODE_ALPHABET = (("A".."Z").to_a - %w[I O]) + %w[2 3 4 5 6 7 8 9]
  CODE_FORMAT = /\A[A-HJ-NP-Z2-9]{6}\z/

  enum :status, {waiting: 0, playing: 1, ended: 2}, default: :waiting

  has_many :players, dependent: :destroy
  has_many :claims, dependent: :destroy
  belongs_to :host_player, class_name: "Player", optional: true
  belongs_to :claiming_player, class_name: "Player", foreign_key: :claim_player_id, optional: true

  validates :code, presence: true, uniqueness: true, format: {with: CODE_FORMAT}

  before_validation :generate_code, on: :create
  after_update_commit :broadcast_game_state

  def start!
    shuffled = (0..80).to_a.shuffle
    update!(status: :playing, board: shuffled.first(12), deck: shuffled.drop(12), discard: [])
  end

  def board_cards
    board.map { |id| Card.new(id) }
  end

  def claim_active?
    claim_player_id.present?
  end

  def try_claim!(player)
    with_lock do
      return nil unless playing?
      return nil if claim_active?
      return nil if player.locked?

      claim = claims.create!(player: player, started_at: Time.current, result: :pending)
      update!(claim_player_id: player.id, claim_started_at: Time.current)
      ExpireClaimJob.set(wait: 5.seconds).perform_later(claim)
      claim
    end
  end

  def release_claim!
    update!(claim_player_id: nil, claim_started_at: nil)
  end

  private

  def broadcast_game_state
    broadcast_replace_to "game:#{code}",
      target: "board",
      partial: "games/board",
      locals: {game: self}
    broadcast_replace_to "game:#{code}",
      target: "scoreboard",
      partial: "games/scoreboard",
      locals: {game: self}
    broadcast_replace_to "game:#{code}",
      target: "announcement",
      partial: "games/announcement",
      locals: {game: self}
    players.each do |player|
      player.broadcast_replace_to "player:#{player.id}",
        target: "controller_status",
        partial: "players/controller_status",
        locals: {player: player}
    end
  end

  def generate_code
    return if code.present?

    loop do
      candidate = Array.new(6) { CODE_ALPHABET.sample }.join
      unless Game.exists?(code: candidate)
        self.code = candidate
        break
      end
    end
  end
end
