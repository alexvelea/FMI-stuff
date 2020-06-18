class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  has_many :notifications, foreign_key: 'user_id', class_name: 'BaseNotification'

  has_many :users_games
  has_many :games, through: :users_games

  before_validation :add_random_user_name

  ADJECTIVES = [
      'Extinct',
      'Flying',
      'Giant',
      'Great',
      'Magical',
      'Common',
      'Nocturnal',
      'Rogue',
      'Beautifull',
      'Tamed',
  ]

  ANIMALS = [
      'Unicorn',
      'Giraffe',
      'Penguin',
      'Dog',
      'Cat',
      'Lion',
      'Sloth',
      'Bee',
      'Fish'
  ]

  def add_random_user_name
    self.name = gen_random_name
  end

  def gen_random_name
    name = ADJECTIVES[rand(ADJECTIVES.length)] + ANIMALS[rand(ANIMALS.length)]
    if User.where(name: name).length != 0
      puts name
      gen_random_name
    else
      name
    end
  end

  def active_games
    sql = "SELECT g.*
          FROM users u
          JOIN users_games ug
          ON u.id = ug.user_id
          JOIN games g
          ON ug.game_id = g.id
          WHERE u.id = #{id} AND is_finished = 0"

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
    end
  end
end
