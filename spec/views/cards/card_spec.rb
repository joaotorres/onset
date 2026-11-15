require "rails_helper"

RSpec.describe "cards/_card", type: :view do
  def render_twice(card)
    render inline: '<%= render "cards/card", card: card %><%= render "cards/card", card: card %>', locals: {card: card}
    Nokogiri::HTML5.fragment(rendered).css("svg")
  end

  def svg_for(card) = Nokogiri::HTML5.fragment(render(partial: "cards/card", locals: {card: card})).at_css("svg")

  def url_refs(svg)
    svg.css("[fill^='url(']").map { |el| el["fill"][/\Aurl\(#(.+)\)\z/, 1] }
  end

  it "gives each rendering of a striped card its own pattern id, referenced from inside that SVG" do
    svgs = render_twice(Card.new(1)) # color 0, striped

    ids = svgs.map { |svg| svg.at_css("pattern")["id"] }
    expect(ids.uniq.size).to eq(2)

    svgs.zip(ids).each do |svg, id|
      refs = url_refs(svg)
      expect(refs).not_to be_empty
      expect(refs.uniq).to eq([id])
    end
  end

  it "renders the striped hatch: 40 degrees, 3.5px lines, 7px pitch, in the card color" do
    svg = render_twice(Card.new(10)).first # color 1, striped
    pattern = svg.at_css("pattern")

    expect(pattern["patternTransform"]).to eq("rotate(40)")
    expect(pattern["width"]).to eq("7")
    expect(pattern["height"]).to eq("7")
    line = pattern.at_css("rect")
    expect(line["width"]).to eq("3.5")
    expect(line["fill"]).to be_nil
    expect(line["class"]).to include("card-ink")
    expect(svg["class"]).to include("card-c1")
  end

  it "renders solid and outline cards with their stroke widths and no fill attribute for solid" do
    solid = svg_for(Card.new(0))
    expect(solid.css("ellipse").map { |e| e["fill"] }).to eq([nil])
    expect(solid.css("ellipse").map { |e| e["class"] }).to eq(["card-shape card-ink"])
    expect(solid.css("ellipse").map { |e| e["stroke-width"] }).to eq(["0"])

    outline = svg_for(Card.new(2))
    expect(outline.css("ellipse").map { |e| e["fill"] }).to eq(["none"])
    expect(outline.css("ellipse").map { |e| e["stroke-width"] }).to eq(["5"])
  end

  # SPEC §10 Palette: the colors come from CSS keyed on <html>, so the markup
  # holds no card color at all.
  it "writes no card color hex value" do
    (0..80).step(4).each do |id|
      html = svg_for(Card.new(id)).to_html
      expect(html.scan(/#\h{6}/i).map(&:upcase).uniq - ["#FAFAFA", "#E5E5E5"]).to eq([]), "card #{id}"
    end
  end

  # DESIGN v6 cards/_card, Color mark: top-left and again turned 180° bottom-right.
  {0 => 3, 1 => 12, 2 => 10}.each do |color, points|
    it "always holds the two color marks of color #{color}, a #{%w[triangle plus star][color]}" do
      svg = svg_for(Card.new(color * 9))
      marks = svg.css(".color-mark")
      expect(marks.size).to eq(2)
      marks.each do |mark|
        expect(mark.name).to eq("polygon")
        expect(mark["points"].split.size).to eq(points)
        expect(mark["class"]).to include("card-ink")
      end
      expect(marks.map { |m| m["transform"] }).to eq(["translate(22 20)", "translate(178 260) rotate(180)"])
    end
  end
end
