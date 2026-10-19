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

  def keep_out_of_search_results
    response.headers["X-Robots-Tag"] = "noindex"
  end
end
