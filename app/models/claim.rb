class Claim < ApplicationRecord
  enum :result, {pending: 0, correct: 1, wrong: 2, expired: 3}, default: :pending

  belongs_to :game
  belongs_to :player

  validates :started_at, presence: true
  validate :card_ids_valid, if: -> { card_ids.present? }

  # The time ran out (§2, §11): judge the picks the claim holds. The caller
  # (ExpireClaimJob) holds the game lock and has checked the claim is pending.
  def expire!
    picks = card_ids || []

    if picks.size < 3
      resolve_expired!
    elsif Card.valid_set?(*picks.map { |id| Card.new(id) })
      resolve_correct!(picks)
    else
      resolve_wrong!(picks)
    end
  end

  # Replaces the picks of a pending claim; an invalid selection is ignored.
  def pick!(ids)
    game.with_lock do
      return unless reload.pending?
      return unless valid_selection?(ids)

      update!(card_ids: ids)
    end
  end

  private

  def valid_selection?(ids)
    return false unless ids.is_a?(Array) && ids.size <= 3
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

    update!(result: :correct, card_ids: submitted_ids, resolved_at: Time.current)
    player.increment!(:score)
    quick_ended = game.quick? && player.score >= Game::QUICK_WIN_SCORE
    game.update!(
      board: new_board_final,
      deck: game.deck.drop(needed),
      discard: game.discard + submitted_ids,
      claim_player_id: nil,
      claim_started_at: nil,
      flash_claim_id: id,
      last_dealt: drawn,
      status: (game_ended || quick_ended) ? :ended : :playing
    )
    ClearClaimFlashJob.set(wait: 3.seconds).perform_later(self)
    ClearLastDealtJob.set(wait: 3.seconds).perform_later(game, drawn) if drawn.any?
  end

  def resolve_expired!
    update!(result: :expired, resolved_at: Time.current, penalized: player.score.positive?)
    lock_out!
  end

  def resolve_wrong!(submitted_ids)
    update!(result: :wrong, card_ids: submitted_ids, resolved_at: Time.current, penalized: player.score.positive?)
    lock_out!
  end

  def lock_out!
    player.update!(score: [player.score - 1, 0].max, locked_until: Game::CLAIM_TIMEOUT.seconds.from_now)
    game.update!(claim_player_id: nil, claim_started_at: nil, flash_claim_id: id)
    ClearClaimFlashJob.set(wait: 3.seconds).perform_later(self)
    UnlockBroadcastJob.set(wait: Game::CLAIM_TIMEOUT.seconds).perform_later(player)
  end

  # At most 3 picks while pending or expired, exactly 3 once judged (§4).
  def card_ids_valid
    sizes = (correct? || wrong?) ? [3] : (0..3)
    unless card_ids.is_a?(Array) && sizes.include?(card_ids.size) &&
        card_ids == card_ids.uniq &&
        card_ids.all? { |id| id.is_a?(Integer) && (0..80).cover?(id) }
      errors.add(:card_ids, "must be distinct integers in 0..80: at most 3 while pending or expired, exactly 3 once judged")
    end
  end
end
