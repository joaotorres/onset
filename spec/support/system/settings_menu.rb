# Settings menu helpers (SPEC §8 Settings menu), on the shared theme ones.
RSpec.shared_context "settings menu" do
  include_context "theme"

  def record_tracks
    page.execute_script("window.tracks = []; window.jtTrack = (name, props) => window.tracks.push([name, props])")
  end

  def tracks = page.evaluate_script("window.tracks")

  # A real pointer tap at the element's centre, whatever lies on top of it.
  def tap_on(element)
    r = page.evaluate_script("(el => { const r = el.getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2] })(arguments[0])", element)
    page.driver.browser.action.move_to_location(r[0].round, r[1].round).click.perform
  end

  def open_settings
    find('button[aria-label="Settings"]').click
    expect(page).to have_css('[role="dialog"][aria-label="Settings"]', visible: true)
  end
end
