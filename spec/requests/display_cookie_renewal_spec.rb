require "rails_helper"

# SPEC §10 Themes and Palette, "Stored per browser": every page the layout
# renders sends each accepted display cookie back with a fresh year, since
# Safari caps a cookie a script writes at 7 days but keeps one the server sends.
RSpec.describe "Display cookie renewal" do
  include_context "players"

  def set_cookie_lines
    Array(response.headers["Set-Cookie"]).flat_map { |h| h.split("\n") }
  end

  def renewed(name) = set_cookie_lines.find { |l| l.start_with?("#{name}=") }

  def expect_renewed(name, value)
    line = renewed(name)
    expect(line).to be_present, "no Set-Cookie for #{name}"
    parts = line.split(/;\s*/)
    expect(parts.first).to eq("#{name}=#{value}")
    attrs = parts.drop(1).map(&:downcase)
    expect(attrs).to include("path=/")
    expect(attrs).to include("samesite=lax")
    expect(attrs).not_to include("httponly")
    expires = parts.find { |p| p.downcase.start_with?("expires=") }
    expect(Time.httpdate(expires.split("=", 2).last)).to be_within(1.minute).of(1.year.from_now)
  end

  def join!(name = "Alice", color = "#E74C3C")
    post game_players_path(game.code), params: {player: {name: name, color: color}}
  end

  pages = {
    "landing" => -> { get root_path },
    "How to play" => -> { get how_to_play_path },
    "join page" => -> { get join_game_players_path(game.code) },
    "big screen" => -> { get game_path(game.code) },
    "player screen" => -> {
      join!
      get game_controller_path(game.code)
    }
  }

  pages.each do |name, visit|
    it "renews theme=light on the #{name}" do
      cookies[:theme] = "light"
      instance_exec(&visit)
      expect(response).to have_http_status(:ok)
      expect_renewed("theme", "light")
    end
  end

  it "renews theme=dark alone" do
    cookies[:theme] = "dark"
    get root_path
    expect_renewed("theme", "dark")
    expect(renewed("card_colors")).to be_nil
  end

  it "renews card_colors=colorblind alone" do
    cookies[:card_colors] = "colorblind"
    get how_to_play_path
    expect_renewed("card_colors", "colorblind")
    expect(renewed("theme")).to be_nil
  end

  it "renews both cookies on one response" do
    cookies[:card_colors] = "colorblind"
    cookies[:theme] = "light"
    get root_path
    expect_renewed("theme", "light")
    expect_renewed("card_colors", "colorblind")
  end

  it "sets neither cookie without one, and never sends back a value it does not accept" do
    get root_path
    expect(renewed("theme")).to be_nil
    expect(renewed("card_colors")).to be_nil

    cookies[:theme] = "blue"
    cookies[:card_colors] = "x"
    get how_to_play_path
    expect(renewed("theme")).to be_nil
    expect(renewed("card_colors")).to be_nil
  end

  it "renews on the join page rendered back with a taken name" do
    join!("Alice", Player::PRESET_COLORS[0])
    cookies[:theme] = "dark"
    cookies[:card_colors] = "colorblind"
    join!("Alice", Player::PRESET_COLORS[1])
    expect(response).to have_http_status(:unprocessable_content)
    expect_renewed("theme", "dark")
    expect_renewed("card_colors", "colorblind")
  end

  it "renews on none of a 204 action, the clock and a redirect" do
    join!
    cookies[:theme] = "light"
    cookies[:card_colors] = "colorblind"

    post ready_game_path(game.code)
    expect(response).to have_http_status(:no_content)
    expect(renewed("theme")).to be_nil
    expect(renewed("card_colors")).to be_nil

    get "/clock"
    expect(renewed("theme")).to be_nil
    expect(renewed("card_colors")).to be_nil

    get join_by_code_path(code: game.code)
    expect(response).to have_http_status(:redirect)
    expect(renewed("theme")).to be_nil
    expect(renewed("card_colors")).to be_nil
  end
end
