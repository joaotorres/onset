module TrackingHelper
  # Events for the track controller to send once, as [name, props] pairs.
  def tracked_events_tag(events)
    tag.div(hidden: true, data: {controller: "track", track_events_value: events.to_json}) if events.present?
  end

  # The game state events a player screen sends (game_events_controller.js).
  # Every player's screen keeps track of the status; only the player at the
  # top of the standings reports, so each event is counted once.
  def game_events_tag(game, player)
    tag.div(hidden: true, data: {
      controller: "game-events",
      game_events_code_value: game.code,
      game_events_status_value: game.status,
      game_events_reporter_value: game.standings.first == player,
      game_events_props_value: game_event_props(game).to_json
    })
  end

  private

  def game_event_props(game)
    props = {mode: game.mode, player_count: game.players.size}
    return props unless game.ended?

    props.merge(end_reason: end_reason(game), is_tie: game.winner.nil?)
  end

  def end_reason(game)
    active_ids = game.players.select(&:active?).map(&:id)
    if game.quick? && game.standings.first.score >= Game::QUICK_WIN_SCORE
      "quick_win"
    elsif active_ids.any? && (active_ids - game.end_game_voters).empty?
      "vote"
    else
      "deck_exhausted"
    end
  end
end
