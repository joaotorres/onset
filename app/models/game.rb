class Game < ApplicationRecord
  CODE_ALPHABET = (("A".."Z").to_a - %w[I O]) + %w[2 3 4 5 6 7 8 9]
  CODE_FORMAT = /\A[A-HJ-NP-Z2-9]{6}\z/
  CLAIM_TIMEOUT = 10

  enum :status, {waiting: 0, playing: 1, ended: 2}, default: :waiting

  has_many :players, dependent: :destroy
  has_many :claims, dependent: :destroy
  belongs_to :host_player, class_name: "Player", optional: true
  belongs_to :claiming_player, class_name: "Player", foreign_key: :claim_player_id, optional: true
  belongs_to :no_set_caller, class_name: "Player", foreign_key: :no_set_caller_id, optional: true

  validates :code, presence: true, uniqueness: true, format: {with: CODE_FORMAT}

  before_validation :generate_code, on: :create
  after_update_commit :broadcast_game_state

  def start!
    shuffled = (0..80).to_a.shuffle
    update!(status: :playing, board: shuffled.first(12), deck: shuffled.drop(12), discard: [])
  end

  def restart!
    with_lock do
      shuffled = (0..80).to_a.shuffle
      players.each { |p| p.update!(score: 0, locked_until: nil) }
      update!(
        status: :playing,
        board: shuffled.first(12),
        deck: shuffled.drop(12),
        discard: [],
        claim_player_id: nil,
        claim_started_at: nil,
        no_set_caller_id: nil,
        no_set_started_at: nil,
        no_set_voters: []
      )
    end
  end

  def board_cards
    board.map { |id| Card.new(id) }
  end

  def claim_active?
    claim_player_id.present?
  end

  def no_set_active?
    no_set_started_at.present?
  end

  def try_claim!(player)
    with_lock do
      return nil unless playing?
      return nil if claim_active?
      return nil if player.locked?

      cancel_no_set! if no_set_active?

      claim = claims.create!(player: player, started_at: Time.current, result: :pending)
      update!(claim_player_id: player.id, claim_started_at: Time.current)
      ExpireClaimJob.set(wait: CLAIM_TIMEOUT.seconds).perform_later(claim)
      claim
    end
  end

  def release_claim!
    update!(claim_player_id: nil, claim_started_at: nil)
  end

  def call_no_set!(player)
    with_lock do
      return nil unless playing?
      return nil if claim_active?
      return nil if no_set_active?

      update!(no_set_caller_id: player.id, no_set_started_at: Time.current, no_set_voters: [player.id])
      ExpireNoSetJob.set(wait: 15.seconds).perform_later(self)
      self
    end
  end

  def join_no_set!(player)
    with_lock do
      return nil unless no_set_active?
      return self if no_set_voters.include?(player.id)

      new_voters = no_set_voters + [player.id]
      update!(no_set_voters: new_voters)
      resolve_no_set! if all_active_players_voted?
      self
    end
  end

  def cancel_no_set!
    update!(no_set_caller_id: nil, no_set_started_at: nil, no_set_voters: [])
  end

  def resolve_no_set!
    can_add = [3, 18 - board.size, deck.size].min
    drawn = deck.first(can_add)
    new_board = board + drawn
    new_deck = deck.drop(can_add)

    game_ended = new_deck.empty? && !Card.any_set_on?(new_board.map { |id| Card.new(id) })

    update!(
      board: new_board,
      deck: new_deck,
      no_set_caller_id: nil,
      no_set_started_at: nil,
      no_set_voters: [],
      status: game_ended ? :ended : :playing
    )
  end

  private

  def all_active_players_voted?
    active_ids = players.select(&:active?).map(&:id)
    active_ids.any? && (active_ids - no_set_voters).empty?
  end

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
