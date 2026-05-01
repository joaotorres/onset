class Claim < ApplicationRecord
  enum :result, {pending: 0, correct: 1, wrong: 2, expired: 3}, default: :pending

  belongs_to :game
  belongs_to :player

  validates :started_at, presence: true
  validate :card_ids_valid, if: -> { card_ids.present? }

  def expire!
    game.release_claim!
    update!(result: :expired, resolved_at: Time.current)
  end

  def submit!(submitted_ids)
    game.with_lock do
      return unless pending?
      return unless valid_selection?(submitted_ids)

      cards = submitted_ids.map { |id| Card.new(id) }

      if Card.valid_set?(*cards)
        resolve_correct!(submitted_ids)
      else
        resolve_wrong!
      end
    end
  end

  private

  def valid_selection?(ids)
    return false unless ids.is_a?(Array) && ids.size == 3
    return false unless ids == ids.uniq
    return false unless ids.all? { |id| id.is_a?(Integer) && (0..80).cover?(id) }

    (ids - game.board).empty?
  end

  def resolve_correct!(submitted_ids)
    new_board = game.board - submitted_ids
    needed = [12 - new_board.size, 0].max
    drawn = game.deck.first(needed)
    new_board_final = new_board + drawn

    game_ended = drawn.size < needed && !Card.any_set_on?(new_board_final.map { |id| Card.new(id) })

    player.increment!(:score)
    game.update!(
      board: new_board_final,
      deck: game.deck.drop(needed),
      discard: game.discard + submitted_ids,
      claim_player_id: nil,
      claim_started_at: nil,
      status: game_ended ? :ended : :playing
    )
    update!(result: :correct, card_ids: submitted_ids, resolved_at: Time.current)
  end

  def resolve_wrong!
    game.release_claim!
    player.update!(score: player.score - 1, locked_until: 5.seconds.from_now)
    update!(result: :wrong, resolved_at: Time.current)
  end

  def card_ids_valid
    unless card_ids.is_a?(Array) && card_ids.size == 3 &&
        card_ids == card_ids.uniq &&
        card_ids.all? { |id| id.is_a?(Integer) && (0..80).cover?(id) }
      errors.add(:card_ids, "must be exactly 3 distinct integers in 0..80")
    end
  end
end
