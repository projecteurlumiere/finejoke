# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
user, user_2 = nil, nil
user = User.new(email: "abc@abc.com", username: "Joker-1", password: "12345678") unless User.find_by(username: "Joker-1")
user_2 = User.new(email: "def@def.com", username: "Joker-2", password: "12345678") unless User.find_by(username: "Joker-2")

[user, user_2].each { |u| u&.save(validate: false) }

Present.create(name: "Present 1", description: "This is the very first present", icon: "this is an svg icon to be implemented soon") unless Present.find_by(name: "Present 1")

10.times do |i|
  user = User.create!(email: "email@#{i}.com", username: "user_#{i}", password: "12345678")
  game = Game.new(name: "game_#{i}}")
  game.add_user(user, is_host: true)
  game.save!
end
