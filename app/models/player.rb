class Player < ApplicationRecord
  COLOR_FORMAT = /\A#[0-9A-Fa-f]{6}\z/

  belongs_to :game

  validates :name, presence: true, length: {maximum: 20}
  validates :color, presence: true, format: {with: COLOR_FORMAT}, uniqueness: {scope: :game_id, message: "has already been taken in this game"}
  validates :session_token, presence: true, uniqueness: true
  validate :name_unique_within_game

  before_validation :generate_session_token, on: :create
  after_update_commit :broadcast_controller_status

  def active? = last_seen_at.present? && last_seen_at > 30.seconds.ago

  def host? = game.host_player_id == id

  def locked? = locked_until.present? && locked_until > Time.current

  def broadcast_controller_status
    broadcast_replace_to "player:#{id}",
      target: "controller_status",
      partial: "players/controller_status",
      locals: {player: self}
  end

  private

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
