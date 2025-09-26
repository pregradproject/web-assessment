# TPA Categories Seed Data
# This file creates the 4 standard TPA categories

puts 'Seeding TPA categories...'

tpa_categories = TpaCategory.default_categories

tpa_categories.each do |category_attrs|
  category = TpaCategory.find_or_create_by(code: category_attrs[:code]) do |cat|
    cat.name = category_attrs[:name]
    cat.description = category_attrs[:description]
  end

  puts "✓ TPA Category: #{category.name} (#{category.code})"
end

puts "TPA categories seeding completed. Total categories: #{TpaCategory.count}"