class User < ApplicationRecord
  include UserMergeable
  include UserPlaying
  include UserBroadcasting

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :finished_jokes, dependent: :nullify, class_name: :Joke, foreign_key: :punchline_author_id
  has_many :started_jokes, dependent: :nullify, class_name: :Joke, foreign_key: :setup_author_id

  validates :username, presence: true

  def jokes
    finished_jokes.or(started_jokes)
  end
end
