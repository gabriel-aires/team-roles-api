# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Populate initial roles

roles = [
  { name: 'Developer', is_default: true },
  { name: 'Product Owner', is_default: false },
  { name: 'Tester', is_default: false }
]

roles.each do |role|
  Role.find_or_create_by!(name: role[:name]) do |r|
    r.is_default = role[:is_default]
  end
end
