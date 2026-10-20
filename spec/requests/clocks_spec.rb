require "rails_helper"

RSpec.describe "Clock", type: :request do
  it "answers the server's current time in ms, never cached" do
    get "/clock"

    expect(response).to have_http_status(:ok)
    now = response.parsed_body["now"]
    expect(now).to be_within(1000).of((Time.current.to_f * 1000).round)
    expect(response.headers["Cache-Control"]).to include("no-store")
  end
end
