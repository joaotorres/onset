require "rails_helper"

RSpec.describe "Byline footer" do
  let(:game) { Game.create! }

  def byline = Nokogiri::HTML(response.body).at_css("footer.byline-footer a.byline")

  def expect_byline
    expect(response).to have_http_status(:ok)
    expect(byline["href"]).to eq("https://joaotorr.es")
    expect(byline["target"]).to eq("_blank")
    expect(byline["rel"]).to eq("noopener")
  end

  it "is on the landing" do
    get root_path
    expect_byline
  end

  it "is on How to play" do
    get how_to_play_path
    expect_byline
  end

  it "is on the join page" do
    get join_game_players_path(game.code)
    expect_byline
  end

  it "reads the domain once, with the new tab label" do
    get root_path
    link = byline
    copies = link.css("[aria-hidden=true]").each(&:remove)
    expect(copies.map(&:text)).to eq(%w[joaotorr es])
    expect(link.text).to eq("by joaotorr.es (Opens in a new tab)")
  end

  it "is not on the big screen" do
    get game_path(game.code)
    expect(response).to have_http_status(:ok)
    expect(byline).to be_nil
  end

  it "is not on the player screen" do
    post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(byline).to be_nil
  end
end
