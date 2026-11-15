module LobbiesHelper
  ExampleCard = Data.define(:number, :shape, :shading, :color)

  # number 0..2 means 1..3 shapes; shape 0 oval, 1 squiggle, 2 diamond;
  # shading 0 solid, 1 striped, 2 outline; color 0, 1, 2 red, green, purple
  # in Classic and blue, orange, magenta in Color-blind (SPEC §10 Palette)
  def example_card(number, shape, shading, color)
    render "cards/card", card: ExampleCard.new(number:, shape:, shading:, color:)
  end
end
