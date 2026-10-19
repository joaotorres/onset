require "rails_helper"

# SPEC.md §8, Search engines: the landing and How to play are the public
# pages. Every other response is noindex unless its action opts out.
RSpec.describe "Search engines", type: :request do
  def canonical = Nokogiri::HTML(response.body).at("link[rel='canonical']")&.[]("href")

  it "lets the landing be indexed, canonical to itself" do
    get root_path
    expect(response.headers["X-Robots-Tag"]).to be_nil
    expect(canonical).to eq("https://onset.joaotorr.es/")
  end

  it "lets How to play be indexed, canonical to the page without ?game=" do
    get how_to_play_path(game: "ABCD")
    expect(response.headers["X-Robots-Tag"]).to be_nil
    expect(canonical).to eq("https://onset.joaotorr.es/how-to-play")
  end

  it "keeps the game pages out of search results, with no canonical" do
    game = Game.create!
    [game_path(game.code), join_game_players_path(game.code), new_game_player_path(game.code)].each do |path|
      get path
      expect(response.headers["X-Robots-Tag"]).to eq("noindex"), path
      expect(canonical).to be_nil
    end
  end

  it "keeps a join by code redirect out of search results" do
    get join_by_code_path(code: "ZZZZ")
    expect(response.headers["X-Robots-Tag"]).to eq("noindex")
  end

  it "lets robots crawl everything and points them to the sitemap" do
    robots = Rails.public_path.join("robots.txt").read
    expect(robots).to include("User-agent: *\nAllow: /")
    expect(robots).not_to include("Disallow")
    expect(robots).to include("Sitemap: https://onset.joaotorr.es/sitemap.xml")
  end

  it "lists exactly the public pages in the sitemap" do
    sitemap = Rails.public_path.join("sitemap.xml").read
    expect(sitemap.scan(%r{<loc>(.*?)</loc>}).flatten)
      .to eq(%w[https://onset.joaotorr.es/ https://onset.joaotorr.es/how-to-play])
  end
end
