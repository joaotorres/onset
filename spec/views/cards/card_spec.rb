require "rails_helper"

RSpec.describe "cards/_card", type: :view do
  def render_twice(card)
    render inline: '<%= render "cards/card", card: card %><%= render "cards/card", card: card %>', locals: {card: card}
    Nokogiri::HTML5.fragment(rendered).css("svg")
  end

  def url_refs(svg)
    svg.css("[fill^='url(']").map { |el| el["fill"][/\Aurl\(#(.+)\)\z/, 1] }
  end

  it "gives each rendering of a striped card its own pattern id, referenced from inside that SVG" do
    svgs = render_twice(Card.new(1)) # blue, striped

    ids = svgs.map { |svg| svg.at_css("pattern")["id"] }
    expect(ids.uniq.size).to eq(2)

    svgs.zip(ids).each do |svg, id|
      refs = url_refs(svg)
      expect(refs).not_to be_empty
      expect(refs.uniq).to eq([id])
    end
  end

  it "renders the striped hatch: 40 degrees, 3.5px lines, 7px pitch, in the card color" do
    svg = render_twice(Card.new(10)).first # orange, striped
    pattern = svg.at_css("pattern")

    expect(pattern["patternTransform"]).to eq("rotate(40)")
    expect(pattern["width"]).to eq("7")
    expect(pattern["height"]).to eq("7")
    line = pattern.at_css("rect")
    expect(line["width"]).to eq("3.5")
    expect(line["fill"]).to eq("#FE6100")
  end

  it "renders solid and outline cards with their plain fills" do
    solid = render_twice(Card.new(0)).first
    expect(solid.css("ellipse").map { |e| e["fill"] }).to eq(["#648FFF"])
    expect(solid.css("ellipse").map { |e| e["stroke-width"] }).to eq(["0"])

    outline = Nokogiri::HTML5.fragment(render(partial: "cards/card", locals: {card: Card.new(2)})).at_css("svg")
    expect(outline.css("ellipse").map { |e| e["fill"] }).to eq(["none"])
    expect(outline.css("ellipse").map { |e| e["stroke-width"] }).to eq(["5"])
  end
end
