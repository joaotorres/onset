class Card
  ATTRS = %i[number color shape shading].freeze

  attr_reader :id

  def initialize(id) = @id = id

  def number = id / 27
  def color = (id / 9) % 3
  def shape = (id / 3) % 3
  def shading = id % 3

  def self.deck = (0..80).map { |i| new(i) }

  def self.valid_set?(a, b, c)
    ATTRS.all? do |attr|
      vs = [a.public_send(attr), b.public_send(attr), c.public_send(attr)]
      vs.uniq.size == 1 || vs.uniq.size == 3
    end
  end

  def self.any_set_on?(cards)
    cards.combination(3).any? { |trio| valid_set?(*trio) }
  end
end
