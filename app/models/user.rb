class User < ApplicationRecord
  include UserPlaying
  include UserBroadcasting

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :finished_jokes, dependent: :nullify, class_name: :Joke
  has_many :started_jokes, dependent: :nullify, class_name: :Joke, foreign_key: :punchline_author

  validates :username, presence: true

  def jokes
    finished_jokes.or(started_jokes)
  end
end
