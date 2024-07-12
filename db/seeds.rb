# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.new(email: "abc@abc.com", username: "Joker-1", password: "12345678")
user_2 = User.new(email: "def@def.com", username: "Joker-2", password: "12345678")
[user, user_2].each { |u| u.save(validate: false) }

Present.create(name: "Present 1", description: "This is the very first present", icon: "this is an svg icon to be implemented soon")
