require "rails_helper"

# jt_telemetry's head script defines window.jtTrack and, in production, loads
# PostHog.
RSpec.describe "Telemetry tag" do
  it "is in the head of a page" do
    get root_path
    scripts = Nokogiri::HTML(response.body).css("head script").map(&:text).join
    expect(scripts).to include("window.jtTrack = function")
  end
end
