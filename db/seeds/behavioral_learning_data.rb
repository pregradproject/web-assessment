# Create Behavioral Learning Categories
behavioral_learning_categories = [
  { code: 'M', name: 'Motivation', description: 'Measures internal drive and goal-setting behavior' },
  { code: 'A', name: 'Engagement', description: 'Measures level of involvement and participation' },
  { code: 'H', name: 'Habits', description: 'Measures consistency and routine formation' },
  { code: 'R', name: 'Self-Regulation', description: 'Measures ability to control and manage behavior' }
]

behavioral_learning_categories.each do |category_data|
  BehavioralLearningCategory.find_or_create_by(code: category_data[:code]) do |category|
    category.name = category_data[:name]
    category.description = category_data[:description]
  end
end

# Create Default Threshold Levels
threshold_levels = [
  {
    label: 'Low',
    message: "You're at the beginning of your journey. Let's build your motivation!",
    min_threshold: 1.0,
    max_threshold: 2.49,
    priority: 1
  },
  {
    label: 'Medium',
    message: "You're progressing well. Keep building those habits!",
    min_threshold: 2.5,
    max_threshold: 3.49,
    priority: 2
  },
  {
    label: 'High',
    message: "Excellent behavior and self-regulation. Keep it up!",
    min_threshold: 3.5,
    max_threshold: 5.0,
    priority: 3
  }
]

threshold_levels.each do |level_data|
  BehavioralLearningThresholdLevel.find_or_create_by(priority: level_data[:priority]) do |level|
    level.label = level_data[:label]
    level.message = level_data[:message]
    level.min_threshold = level_data[:min_threshold]
    level.max_threshold = level_data[:max_threshold]
    level.active = true
  end
end

# Create Sample Question Set
question_set = BehavioralLearningQuestionSet.find_or_create_by(name: 'Default Behavioral Learning Assessment') do |qs|
  qs.version = 'v1.0'
  qs.active = true
  qs.time_limit = 1800
end

# Sample questions for each category
sample_questions = [
  { category: 'M', question: 'I set clear, achievable goals for myself.' },
  { category: 'M', question: 'I feel motivated to work toward my objectives.' },
  { category: 'M', question: 'I maintain enthusiasm even when facing challenges.' },
  { category: 'A', question: 'I actively participate in learning activities.' },
  { category: 'A', question: 'I engage fully when working on tasks.' },
  { category: 'A', question: 'I seek out opportunities to get involved.' },
  { category: 'H', question: 'I maintain consistent daily routines.' },
  { category: 'H', question: 'I follow through on my commitments.' },
  { category: 'H', question: 'I stick to productive habits regularly.' },
  { category: 'R', question: 'I can control my impulses when necessary.' },
  { category: 'R', question: 'I manage my emotions effectively.' },
  { category: 'R', question: 'I adjust my behavior based on feedback.' }
]

sample_questions.each do |question_data|
  category = BehavioralLearningCategory.find_by(code: question_data[:category])
  next unless category

  question_set.behavioral_learning_questions.find_or_create_by(body: question_data[:question]) do |question|
    question.behavioral_learning_category = category
  end

  # Create question set category association
  question_set.behavioral_learning_question_set_categories.find_or_create_by(
    behavioral_learning_category: category
  )
end

# Configuration for pricing
Config.find_or_create_by!(key: 'behavioral_learning_price') do |config|
  config.value = '40000'
  config.value_type = 'integer'
  config.description = 'Price for Behavioral Learning test in IDR'
end

puts "Created #{BehavioralLearningCategory.count} behavioral learning categories"
puts "Created #{BehavioralLearningThresholdLevel.count} threshold levels"
puts "Created #{BehavioralLearningQuestionSet.count} question sets"
puts "Created #{BehavioralLearningQuestion.count} questions"
