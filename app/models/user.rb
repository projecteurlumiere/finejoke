class User < ApplicationRecord
  include Localizable
  include Users::Mergeable
  include Users::Playing
  include Users::Broadcasting

  INACTIVE_PERIOD_BEFORE_DESTROY_GUEST = 1.week

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  validates :username, presence: true, uniqueness: true

  before_create :random_name, if: %i[new_record? guest?] 
  has_many :awards, dependent: :destroy

  has_many :jokes, dependent: :nullify
  has_many :setups, dependent: :nullify

  validates :username, presence: true, length: { in: 1..14 }
  normalizes :username, with: -> (s) { s.strip }
  
  def set_default_locale
    self.locale = I18n.locale
  end

  def random_name
    self.username = "#{I18n.t(:"round.joker")}_#{SecureRandom.hex(10)}".slice(0, 13)
  end

  def started_jokes
    Joke.where(setup_model: { user_id: id }).joins(:setup_model)
  end

  def finished_jokes
    Joke.where(user_id: id)
  end

  def jokes
    started_jokes.or(finished_jokes)
  end

  def to_s
    username
  end
end
