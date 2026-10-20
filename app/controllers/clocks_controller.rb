# SPEC.md §6, Server-side timers: pages measure their offset from this clock
# so countdowns read the server's time. Never cached, or the time goes stale.
class ClocksController < ApplicationController
  def show
    response.headers["Cache-Control"] = "no-store"
    render json: {now: (Time.current.to_f * 1000).round}
  end
end
