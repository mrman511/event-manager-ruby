# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Todo.destroy_all
puts "Destroyed Todo items"

Todo.create!(title: "Create automated tests", status: "Not started", is_completed: false)
Todo.create!(title: "Create User Model", status: "Not started", is_completed: false)

puts "Created Todo items"

User.destroy_all
User.create!(email: "bodner80@gmail.com", password: ENV["VALID_PASSWORD_TEST"])
