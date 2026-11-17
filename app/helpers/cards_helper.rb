# DESIGN v6 cards/_card: the color mark per card color (triangle, plus,
# five-point star), shown under Color-blind only. Read by the card and by the
# settings menu's Color-blind chip.
module CardsHelper
  COLOR_MARKS = [
    "0,-14 14,12 -14,12",
    "-4.5,-14 4.5,-14 4.5,-4.5 14,-4.5 14,4.5 4.5,4.5 4.5,14 -4.5,14 -4.5,4.5 -14,4.5 -14,-4.5 -4.5,-4.5",
    "0,-13.5 3.64,-3.52 14.27,-3.14 5.9,3.42 8.82,13.64 0,7.7 -8.82,13.64 -5.9,3.42 -14.27,-3.14 -3.64,-3.52"
  ].freeze
end
