require "rails_helper"

# SPEC.md §7, Screens ignore broadcasts older than what they show.
RSpec.describe "Stale broadcasts", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }

  def page_version(id) = find("##{id}")["data-version"].to_i

  def replace(target, html)
    Turbo::StreamsChannel.broadcast_replace_to("game:#{game.code}", target: target, html: html)
  end

  def tile(version, text)
    version_attr = version ? %( data-version="#{version}") : ""
    %(<div id="room_tile"#{version_attr}><p>#{text}</p></div>)
  end

  before do
    visit game_path(game.code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
    expect(page).to have_css("#room_tile[data-version]")
  end

  it "drops a replace older than the region it targets" do
    stamped = page_version("room_tile")
    replace("room_tile", tile(stamped - 1, "STALE MARKER"))
    replace("announcement", %(<div id="announcement" data-version="#{page_version("announcement") + 1}"><p>SENTINEL</p></div>))

    expect(page).to have_css("#announcement", text: "SENTINEL")
    expect(page).not_to have_content("STALE MARKER")
    expect(page_version("room_tile")).to eq(stamped)
  end

  it "renders a replace at the same version" do
    replace("room_tile", tile(page_version("room_tile"), "EQUAL MARKER"))
    expect(page).to have_css("#room_tile", text: "EQUAL MARKER")
  end

  it "renders a replace at a newer version" do
    replace("room_tile", tile(page_version("room_tile") + 1, "NEWER MARKER"))
    expect(page).to have_css("#room_tile", text: "NEWER MARKER")
  end

  it "renders a replace with no version on a stamped region" do
    replace("room_tile", tile(nil, "UNSTAMPED MARKER"))
    expect(page).to have_css("#room_tile", text: "UNSTAMPED MARKER")
  end
end
