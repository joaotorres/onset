class ApplicationController < ActionController::Base
  include TracksEvents

  # SPEC.md §8, Search engines: every page is noindex unless its controller
  # skips this, so a new page stays out of search results. First, so it
  # covers pages a before_action renders too.
  before_action :keep_out_of_search_results

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # SPEC.md §5, Rate limits: a refused in-game request answers 429 with no body.
  def refuse_over_limit
    head :too_many_requests
  end

  # Counted per player, never by the shared table IP; by IP only without the cookie.
  def player_limit_key
    cookies.encrypted[:player_token].presence || request.remote_ip
  end

  # The room the host cookie names; by IP without it, so a stranger never uses up the host's count.
  def host_limit_key
    cookies.encrypted[:host_game].presence || request.remote_ip
  end

  def keep_out_of_search_results
    response.headers["X-Robots-Tag"] = "noindex"
  end
end
