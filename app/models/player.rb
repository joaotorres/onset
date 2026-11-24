class Player < ApplicationRecord
  COLOR_FORMAT = /\A#[0-9A-Fa-f]{6}\z/
  PRESET_COLORS = %w[#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A].freeze

  belongs_to :game

  # Nil for a person. A bot is a player Onset plays itself (SPEC, AI opponent).
  enum :bot_level, {easy: 0, medium: 1, hard: 2}, prefix: :bot

  validates :name, presence: true, length: {maximum: 20}
  validates :color, presence: true, format: {with: COLOR_FORMAT}, uniqueness: {scope: :game_id, message: "has already been taken in this game"}
  # On create only: a room live before this rule may hold a non-preset row.
  validates :color, inclusion: {in: PRESET_COLORS}, on: :create
  validates :session_token, presence: true, uniqueness: true
  validate :name_unique_within_game

  before_validation :generate_session_token, on: :create
  after_create_commit :broadcast_player_joined
  after_update_commit :broadcast_controller_status

  # The lowest free name of a level, "Easy bot", "Easy bot 2", ..., matched
  # case-insensitively against the names taken in the room, people's included.
  def self.bot_name(level, taken_names)
    taken = taken_names.map(&:downcase)
    base = "#{level.to_s.capitalize} bot"
    (1..).each do |n|
      name = (n == 1) ? base : "#{base} #{n}"
      return name unless taken.include?(name.downcase)
    end
  end

  def bot? = bot_level.present?

  # A bot is never active, so every vote that counts active players counts people only (SPEC §2 Edge cases).
  def active? = !bot? && last_seen_at.present? && last_seen_at > 30.seconds.ago

  # Bookkeeping only: skips callbacks because a heartbeat broadcast would
  # show nothing new (SPEC §7).
  def seen! = update_column(:last_seen_at, Time.current)

  def host? = game.host_player_id == id

  def locked? = locked_until.present? && locked_until > Time.current

  # "wrong" or "expired": why the current lockout happened.
  def lockout_reason
    game.claims.where(player: self, result: [:wrong, :expired]).order(:resolved_at).last&.result
  end

  def broadcast_controller_status
    broadcast_replace_to "player:#{id}",
      target: "controller_status",
      partial: "players/controller_status",
      locals: {player: self}
  end

  private

  def broadcast_player_joined
    game.broadcast_lobby_state
  end

  def generate_session_token
    self.session_token ||= SecureRandom.hex(16)
  end

  def name_unique_within_game
    return unless game_id && name

    scope = game.players.where("LOWER(name) = LOWER(?)", name)
    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, "has already been taken in this game") if scope.exists?
  end
end
