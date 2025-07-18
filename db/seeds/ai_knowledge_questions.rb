# AI Knowledge Questions Seed Data
puts "Seeding AI Knowledge Question Set and Questions..."

# Create or find the question set
question_set = AiKnowledgeQuestionSet.find_or_create_by!(version: 1) do |qs|
  qs.name = "AI Knowledge Assessment v1"
  qs.active = true
  qs.time_limit = 0 # No time limit for now
end

puts "  ✓ Question Set: #{question_set.name} (v#{question_set.version})"

# Get categories
categories = AiKnowledgeCategory.all.index_by(&:code)

# Sample questions for each category (we'll create 5 questions per category for a total of 40 questions)
questions_data = [
  # Performance Expectancy (PE) Questions
  {
    category: 'PE',
    body: 'Saya percaya bahwa menggunakan AI akan meningkatkan prestasi akademik saya secara signifikan.',
    max_weight: 5
  },
  {
    category: 'PE',
    body: 'AI membantu saya memahami konsep-konsep rumit dengan lebih mudah dan cepat.',
    max_weight: 5
  },
  {
    category: 'PE',
    body: 'Dengan AI, saya dapat menyelesaikan tugas-tugas akademik dengan kualitas yang lebih baik.',
    max_weight: 5
  },
  {
    category: 'PE',
    body: 'Saya yakin AI memberikan keunggulan kompetitif dalam pembelajaran dibanding metode konvensional.',
    max_weight: 5
  },
  {
    category: 'PE',
    body: 'Menggunakan AI membuat proses belajar saya menjadi lebih efektif dan terukur.',
    max_weight: 5
  },

  # Effort Expectancy (EE) Questions
  {
    category: 'EE',
    body: 'Saya merasa mudah dalam mengoperasikan berbagai aplikasi dan tools AI untuk pembelajaran.',
    max_weight: 5
  },
  {
    category: 'EE',
    body: 'Berinteraksi dengan AI tidak memerlukan usaha mental yang berlebihan bagi saya.',
    max_weight: 5
  },
  {
    category: 'EE',
    body: 'Saya dapat dengan cepat beradaptasi dengan fitur-fitur baru dalam teknologi AI.',
    max_weight: 5
  },
  {
    category: 'EE',
    body: 'Interface dan penggunaan AI terasa intuitif dan user-friendly untuk saya.',
    max_weight: 5
  },
  {
    category: 'EE',
    body: 'Saya tidak mengalami kesulitan teknis yang berarti saat menggunakan AI.',
    max_weight: 5
  },

  # Social Influence (SI) Questions
  {
    category: 'SI',
    body: 'Dosen dan instruktur mendorong penggunaan AI dalam aktivitas pembelajaran di kelas.',
    max_weight: 5
  },
  {
    category: 'SI',
    body: 'Teman-teman sekelas memberikan dukungan positif terhadap penggunaan AI untuk belajar.',
    max_weight: 5
  },
  {
    category: 'SI',
    body: 'Institusi pendidikan saya secara aktif mempromosikan integrasi AI dalam pembelajaran.',
    max_weight: 5
  },
  {
    category: 'SI',
    body: 'Lingkungan akademik saya menciptakan atmosfer yang mendukung eksplorasi teknologi AI.',
    max_weight: 5
  },
  {
    category: 'SI',
    body: 'Orang-orang penting di sekitar saya menganggap penggunaan AI dalam belajar sebagai hal positif.',
    max_weight: 5
  },

  # Facilitating Conditions (FC) Questions
  {
    category: 'FC',
    body: 'Saya memiliki akses internet yang stabil dan perangkat yang memadai untuk menggunakan AI.',
    max_weight: 5
  },
  {
    category: 'FC',
    body: 'Dukungan teknis tersedia ketika saya mengalami masalah dengan aplikasi AI.',
    max_weight: 5
  },
  {
    category: 'FC',
    body: 'Saya memiliki pengetahuan dan keterampilan yang cukup untuk memanfaatkan AI secara optimal.',
    max_weight: 5
  },
  {
    category: 'FC',
    body: 'Infrastruktur teknologi di lingkungan saya mendukung penggunaan AI yang lancar.',
    max_weight: 5
  },
  {
    category: 'FC',
    body: 'Saya dapat mengatasi hambatan teknis yang mungkin muncul saat menggunakan AI.',
    max_weight: 5
  },

  # Hedonic Motivation (HM) Questions
  {
    category: 'HM',
    body: 'Saya menikmati proses belajar dengan bantuan teknologi AI.',
    max_weight: 5
  },
  {
    category: 'HM',
    body: 'Menggunakan AI membuat pembelajaran menjadi lebih menarik dan tidak monoton.',
    max_weight: 5
  },
  {
    category: 'HM',
    body: 'Saya merasa terhibur dan engaged saat berinteraksi dengan aplikasi AI.',
    max_weight: 5
  },
  {
    category: 'HM',
    body: 'Eksplorasi fitur-fitur AI memberikan kepuasan dan kesenangan tersendiri bagi saya.',
    max_weight: 5
  },
  {
    category: 'HM',
    body: 'AI membuat proses pembelajaran menjadi lebih interaktif dan menyenangkan.',
    max_weight: 5
  },

  # Price Value (PV) Questions
  {
    category: 'PV',
    body: 'Investasi waktu dan uang untuk belajar menggunakan AI sebanding dengan manfaat yang saya peroleh.',
    max_weight: 5
  },
  {
    category: 'PV',
    body: 'Cost-benefit ratio penggunaan AI dalam pembelajaran sangat menguntungkan untuk saya.',
    max_weight: 5
  },
  {
    category: 'PV',
    body: 'Saya menganggap biaya berlangganan atau akses AI tools sebagai investasi yang berharga.',
    max_weight: 5
  },
  {
    category: 'PV',
    body: 'Value proposition yang ditawarkan AI sesuai dengan ekspektasi dan kebutuhan saya.',
    max_weight: 5
  },
  {
    category: 'PV',
    body: 'Return on investment dari penggunaan AI terbukti positif untuk pengembangan diri saya.',
    max_weight: 5
  },

  # Habit (HT) Questions
  {
    category: 'HT',
    body: 'Menggunakan AI sudah menjadi bagian natural dari rutinitas belajar harian saya.',
    max_weight: 5
  },
  {
    category: 'HT',
    body: 'Saya secara otomatis membuka aplikasi AI ketika memulai aktivitas pembelajaran.',
    max_weight: 5
  },
  {
    category: 'HT',
    body: 'Penggunaan AI sudah terintegrasi seamlessly dalam workflow akademik saya.',
    max_weight: 5
  },
  {
    category: 'HT',
    body: 'Saya tidak perlu conscious effort untuk memutuskan kapan menggunakan AI dalam belajar.',
    max_weight: 5
  },
  {
    category: 'HT',
    body: 'AI telah menjadi learning companion yang konsisten dalam keseharian saya.',
    max_weight: 5
  },

  # Behavioral Intention (BI) Questions
  {
    category: 'BI',
    body: 'Saya memiliki rencana jangka panjang untuk terus mengembangkan keterampilan AI.',
    max_weight: 5
  },
  {
    category: 'BI',
    body: 'Saya berniat untuk mengintegrasikan AI dalam karir profesional di masa depan.',
    max_weight: 5
  },
  {
    category: 'BI',
    body: 'Saya berkomitmen untuk selalu mengikuti perkembangan terbaru dalam teknologi AI.',
    max_weight: 5
  },
  {
    category: 'BI',
    body: 'Saya merencanakan untuk mengambil kursus atau sertifikasi terkait AI di masa mendatang.',
    max_weight: 5
  },
  {
    category: 'BI',
    body: 'Saya akan merekomendasikan penggunaan AI dalam pembelajaran kepada orang lain.',
    max_weight: 5
  }
]

# Create questions
created_count = 0
questions_data.each do |question_data|
  category = categories[question_data[:category]]
  next unless category

  question = AiKnowledgeQuestion.find_or_create_by!(
    ai_knowledge_question_set: question_set,
    ai_knowledge_category: category,
    body: question_data[:body]
  ) do |q|
    q.max_weight = question_data[:max_weight]
  end

  created_count += 1
  puts "  ✓ #{category.code}: #{question.body[0..50]}..."
end

# Create question set categories (junction table entries)
categories.each do |code, category|
  AiKnowledgeQuestionSetCategory.find_or_create_by!(
    ai_knowledge_question_set: question_set,
    ai_knowledge_category: category
  ) do |qsc|
    qsc.time_limit_secs = 300 # 5 minutes per category section
  end
end

puts "Completed seeding #{created_count} AI Knowledge Questions across 8 categories"
puts "Question set '#{question_set.name}' is now active with #{question_set.total_questions} questions"
