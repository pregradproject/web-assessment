# AI Knowledge Categories Seed Data
puts "Seeding AI Knowledge Categories..."

categories = [
  {
    code: 'PE',
    name: 'Performance Expectancy',
    description: 'Expectation that using AI will improve academic performance and learning effectiveness',
    result_text: 'Strong belief that AI enhances learning outcomes and academic achievement'
  },
  {
    code: 'EE',
    name: 'Effort Expectancy',
    description: 'Perceived ease of use and comfort with AI technology',
    result_text: 'High comfort level and natural ability in using AI tools and applications'
  },
  {
    code: 'SI',
    name: 'Social Influence',
    description: 'Support from social environment for AI adoption in learning',
    result_text: 'Strong social support and positive influence from peers, instructors, and institutions'
  },
  {
    code: 'FC',
    name: 'Facilitating Conditions',
    description: 'Access to infrastructure and resources needed for optimal AI usage',
    result_text: 'Adequate access to technology, resources, and technical support for AI learning'
  },
  {
    code: 'HM',
    name: 'Hedonic Motivation',
    description: 'Enjoyment and intrinsic motivation derived from using AI in learning',
    result_text: 'High enjoyment and intrinsic satisfaction from AI-enhanced learning experiences'
  },
  {
    code: 'PV',
    name: 'Price Value',
    description: 'Perception of cost-benefit ratio and value proposition of AI investment',
    result_text: 'Strong awareness of value and strategic approach to AI technology investment'
  },
  {
    code: 'HT',
    name: 'Habit',
    description: 'Automatic and habitual integration of AI into daily learning routines',
    result_text: 'Seamless and consistent integration of AI tools into learning workflows'
  },
  {
    code: 'BI',
    name: 'Behavioral Intention',
    description: 'Long-term commitment and intention for continued AI development',
    result_text: 'Strong commitment to long-term AI learning and professional development'
  }
]

categories.each do |category_data|
  category = AiKnowledgeCategory.find_or_create_by!(code: category_data[:code]) do |cat|
    cat.name = category_data[:name]
    cat.description = category_data[:description]
    cat.result_text = category_data[:result_text]
  end

  puts "  ✓ #{category.code} - #{category.name}"
end

puts "Completed seeding #{categories.length} AI Knowledge Categories"
