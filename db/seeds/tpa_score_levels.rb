# TPA Score Levels Configuration
puts "Creating TPA score levels configuration..."

# Create default TPA score levels configuration
default_tpa_score_levels = {
  'low' => {
    'name' => 'Kategori Rendah',
    'min_score' => 200,
    'max_score' => 449,
    'label' => 'Kategori Rendah',
    'message' => 'Performa rendah, perlu bimbingan dan persiapan lebih intensif'
  },
  'average' => {
    'name' => 'Kategori Rata-Rata',
    'min_score' => 450,
    'max_score' => 549,
    'label' => 'Kategori Rata-Rata',
    'message' => 'Performa rata-rata, masih ada ruang untuk peningkatan'
  },
  'high' => {
    'name' => 'Kategori Tinggi',
    'min_score' => 550,
    'max_score' => 800,
    'label' => 'Kategori Tinggi',
    'message' => 'Performa tinggi, potensi akademik yang baik'
  }
}

# Create TPA score levels config if it doesn't exist
Config.find_or_create_by!(key: 'tpa_score_levels') do |config|
  config.value = default_tpa_score_levels.to_json
  config.value_type = 'string'
  config.description = 'TPA score level configuration with ranges and labels'
end

puts "TPA score levels configuration created successfully!"
