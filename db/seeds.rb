# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end if Rails.env.development?

# Create default configurations
Config.find_or_create_by!(key: 'vark_price') do |config|
  config.value = '30000'
  config.value_type = 'integer'
  config.description = 'Price for VARK test certificate in IDR'
end

Config.find_or_create_by!(key: 'ai_knowledge_price') do |config|
  config.value = '35000'
  config.value_type = 'integer'
  config.description = 'Price for AI Knowledge test certificate in IDR'
end

puts "Created default configs: vark_price = 30000, ai_knowledge_price = 35000"

# Load VARK result descriptions
load Rails.root.join('db', 'seeds', 'vark_result_descriptions.rb')

# Load AI Knowledge categories, questions, and result descriptions
load Rails.root.join('db', 'seeds', 'ai_knowledge_categories.rb')
load Rails.root.join('db', 'seeds', 'ai_knowledge_questions.rb')
load Rails.root.join('db', 'seeds', 'ai_knowledge_result_descriptions.rb')

# Load Behavioral Learning data
load Rails.root.join('db', 'seeds', 'behavioral_learning_data.rb')
