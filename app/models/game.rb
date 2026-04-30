class Game < ApplicationRecord
  CODE_ALPHABET = (("A".."Z").to_a - %w[I O]) + %w[2 3 4 5 6 7 8 9]
  CODE_FORMAT = /\A[A-HJ-NP-Z2-9]{6}\z/

  has_many :players, dependent: :destroy
  belongs_to :host_player, class_name: "Player", optional: true

  validates :code, presence: true, uniqueness: true, format: {with: CODE_FORMAT}

  before_validation :generate_code, on: :create

  private

  def generate_code
    return if code.present?

    loop do
      candidate = Array.new(6) { CODE_ALPHABET.sample }.join
      unless Game.exists?(code: candidate)
        self.code = candidate
        break
      end
    end
  end
end
