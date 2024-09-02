class User < ApplicationRecord
  include UserMergeable
  include UserPlaying
  include UserBroadcasting

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :random_name, if: %i[new_record? guest?] 
  has_many :awards, dependent: :destroy

  has_many :finished_jokes, dependent: :nullify, class_name: :Joke, foreign_key: :punchline_author_id
  has_many :started_jokes, dependent: :nullify, class_name: :Joke, foreign_key: :setup_author_id

  validates :username, presence: true, length: { in: 1..14 }

  def random_name
    self.username = "Joker_#{SecureRandom.hex(10)}".slice(0, 14)
  end

  def jokes
    finished_jokes.or(started_jokes)
  end
end
