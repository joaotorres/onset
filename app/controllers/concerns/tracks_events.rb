# Custom PostHog events for actions that finish on the server. They ride the
# flash to the next page, where the track controller hands them to jtTrack
# (app/javascript/controllers/track_controller.js).
module TracksEvents
  private

  def track_event(name, **props)
    flash[:tracked_events] = Array(flash[:tracked_events]) + [[name, props]]
  end
end
