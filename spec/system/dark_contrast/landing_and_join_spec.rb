require "rails_helper"

# DESIGN v7 Shared: Themes (v6) Muted, Placeholder and Field border at rest:
# the landing's room code field and the join page's name field and hint.
RSpec.describe "Dark muted text and field borders on the landing and join page", type: :system do
  include_context "settings menu"
  include_context "resizable window"
  include_context "dark contrast"

  let(:game) { Game.create! }

  def theme!(name)
    visit root_path
    theme_cookie!(name)
  end

  it "defines muted once, as a theme token, and no view writes the hex" do
    visit root_path
    expect(token("muted")).to eq("#7c8390")
    expect(Dir["app/views/**/*"].select { |f| File.file?(f) && File.read(f).match?(/7C8390/i) }).to be_empty
  end

  [[1280, 860], [375, 667]].each do |width, height|
    it "gives the room code field a muted placeholder and a gray-500 border in dark at #{width}px" do
      resize(width, height)
      theme!("dark")
      visit root_path
      expect(pseudo_style("#room_code", "::placeholder", "color")).to eq(muted)
      expect(style("#room_code", "border-top-color")).to eq(color("gray-500"))
    end
  end

  it "keeps the error border red in both themes and the placeholder gray-500 in light" do
    resize(1280, 860)
    theme!("dark")
    visit root_path
    fill_in "Have a room code?", with: "ZZZZ"
    click_button "Join"
    expect(page).to have_content("Room not found")
    expect(style("#room_code", "border-top-color")).to eq(color("red-500"))

    theme!("light")
    visit root_path
    expect(pseudo_style("#room_code", "::placeholder", "color")).to eq(color("gray-500"))
    expect(style("#room_code", "border-top-color")).to eq(color("gray-500"))
    fill_in "Have a room code?", with: "ZZZZ"
    click_button "Join"
    expect(page).to have_content("Room not found")
    expect(style("#room_code", "border-top-color")).to eq(color("red-600"))
  end

  it "keeps the landing's Join button border gray-700 in dark" do
    resize(1280, 860)
    theme!("dark")
    visit root_path
    expect(style("input[type=submit]", "border-top-color")).to eq(color("gray-700"))
  end

  it "keeps the Game mode toggle track border gray-700 in dark" do
    resize(1280, 860)
    theme!("dark")
    visit root_path
    expect(style("form[action='#{games_path}'] fieldset > div", "border-top-color")).to eq(color("gray-700"))
  end

  it "keeps the open settings menu border gray-700 in dark" do
    resize(1280, 860)
    theme!("dark")
    visit root_path
    open_settings
    expect(style("#settings_menu", "border-top-color")).to eq(color("gray-700"))
  end

  it "draws the disabled Join label gray-500 on gray-800 in dark when the room is full" do
    Player::PRESET_COLORS.each_with_index { |c, i| game.players.create!(name: "P#{i}", color: c, session_token: "t#{i}") }
    theme!("dark")
    visit new_game_player_path(game.code)
    join = find("input[type=submit][disabled]")
    expect(style_of(join, "color")).to eq(color("gray-500"))
    expect(style_of(join, "background-color")).to eq(color("gray-800"))
  end

  it "draws the join page's name field, placeholder and hint muted in dark, gray-500 in light" do
    game.players.create!(name: "Ana", color: Player::PRESET_COLORS.first, session_token: "t1")
    theme!("dark")
    visit new_game_player_path(game.code)
    page.execute_script("document.activeElement.blur()")
    expect(pseudo_style("#player_name", "::placeholder", "color")).to eq(muted)
    expect(style("#player_name", "border-top-color")).to eq(color("gray-500"))
    expect(style("p.text-sm", "color")).to eq(muted)

    theme!("light")
    visit new_game_player_path(game.code)
    page.execute_script("document.activeElement.blur()")
    expect(pseudo_style("#player_name", "::placeholder", "color")).to eq(color("gray-500"))
    expect(style("#player_name", "border-top-color")).to eq(color("gray-500"))
    expect(style("p.text-sm", "color")).to eq(color("gray-500"))
  end

  it "keeps the join page's name error border red in dark" do
    theme!("dark")
    visit new_game_player_path(game.code)
    fill_in "Your name", with: " "
    click_button "Join"
    expect(page).to have_css("#player_name.border-red-500")
    page.execute_script("document.activeElement.blur()")
    expect(style("#player_name", "border-top-color")).to eq(color("red-500"))
  end

  it "keeps the join page's name error border red-600 in light" do
    theme!("light")
    visit new_game_player_path(game.code)
    fill_in "Your name", with: " "
    click_button "Join"
    expect(page).to have_css("#player_name.border-red-500")
    page.execute_script("document.activeElement.blur()")
    expect(style("#player_name", "border-top-color")).to eq(color("red-600"))
  end
end
