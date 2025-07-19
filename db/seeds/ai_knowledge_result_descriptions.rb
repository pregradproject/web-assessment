# AI Knowledge Result Descriptions Seed Data
puts "Seeding AI Knowledge Result Descriptions..."

# Helper method to create or update result description
def create_result_description(combination_pattern, data)
  result_desc = AiKnowledgeResultDescription.find_or_initialize_by(combination_pattern: combination_pattern)
  result_desc.assign_attributes(data)
  result_desc.save!
  puts "  ✓ #{combination_pattern}: #{data[:title]}"
  result_desc
end

# Single Component Descriptions
single_components = [
  {
    combination_pattern: "PE",
    title: "Performance Expectancy - Ekspektasi Kinerja AI",
    description: "Anda memiliki keyakinan kuat bahwa menggunakan AI dapat meningkatkan prestasi akademik dan efektivitas belajarmu.",
    characteristics: "Anda memiliki keyakinan kuat bahwa menggunakan AI dapat meningkatkan prestasi akademik dan efektivitas belajarmu. Anda percaya bahwa AI membantu memahami konsep yang rumit, menyelesaikan tugas lebih cepat, dan meningkatkan kualitas pemahaman materi. Kekuatanmu terletak pada kemampuan melihat potensi AI sebagai alat yang dapat memberikan keunggulan kompetitif dalam pembelajaran.",
    study_recommendations: "Manfaatkan AI untuk tugas-tugas spesifik seperti analisis data, pembuatan outline essay, dan penjelasan konsep yang sulit dipahami, namun tetap kembangkan kemampuan berpikir kritismu sendiri. Berdasarkan penelitian Wang et al. (2024), penggunaan AI secara strategis dapat meningkatkan prestasi akademik hingga 23% ketika digunakan sebagai tutor personal dan asisten pembelajaran.",
    career_suggestions: "Fokus pada bidang yang memanfaatkan AI untuk peningkatan performa seperti data analytics, research, academic consulting, atau educational technology development.",
    strengths: "Visi strategis dalam pemanfaatan teknologi, orientasi hasil, kemampuan mengidentifikasi value proposition AI",
    potential_challenges: "Hindari over-expectation, penting untuk memahami limitasi AI dan tetap mengembangkan kemampuan fundamental"
  },
  {
    combination_pattern: "EE",
    title: "Effort Expectancy - Ekspektasi Kemudahan Penggunaan",
    description: "Anda memiliki kemampuan baik dalam mengoperasikan teknologi AI dengan mudah dan efisien.",
    characteristics: "Anda memiliki kemampuan baik dalam mengoperasikan teknologi AI dengan mudah dan efisien. Anda merasa nyaman berinteraksi dengan aplikasi AI dan tidak memerlukan usaha mental yang berlebihan untuk menggunakannya. Kekuatanmu adalah kemampuan adaptasi teknologi yang memungkinkan fokus pada pembelajaran daripada terjebak dalam kompleksitas teknis.",
    study_recommendations: "Mulai dengan AI tools yang user-friendly seperti ChatGPT atau Gemini untuk tugas-tugas sederhana, kemudian bertahap tingkatkan ke fitur yang lebih advanced seiring meningkatnya kemampuanmu. Penelitian Li et al. (2022) menunjukkan bahwa mahasiswa yang memulai dengan eksplorasi bertahap memiliki acceptance rate 67% lebih tinggi terhadap teknologi AI.",
    career_suggestions: "User experience design, technical training, digital adoption consulting, atau technology support specialist",
    strengths: "Natural tech aptitude, kemampuan adaptasi cepat, efficiency dalam penggunaan tools",
    potential_challenges: "Jaga agar tidak terlalu bergantung pada kemudahan - tetap challenge diri dengan teknologi yang lebih complex"
  },
  {
    combination_pattern: "SI",
    title: "Social Influence - Pengaruh Sosial",
    description: "Anda memiliki lingkungan akademik yang mendukung penggunaan AI dalam pembelajaran.",
    characteristics: "Anda memiliki lingkungan akademik yang mendukung penggunaan AI dalam pembelajaran. Dosen, teman, dan institusi pendidikanmu memberikan dorongan positif untuk mengintegrasikan AI dalam aktivitas belajar. Kekuatanmu terletak pada support system yang kuat yang memfasilitasi eksplorasi teknologi AI secara aman dan terarah.",
    study_recommendations: "Manfaatkan dukungan lingkungan dengan aktif berpartisipasi dalam study group yang menggunakan AI, mengikuti workshop atau seminar tentang AI yang diselenggarakan kampus, dan berdiskusi dengan dosen tentang best practices penggunaan AI.",
    career_suggestions: "Community management, training and development, change management, atau social innovation consulting",
    strengths: "Strong networking ability, collaborative mindset, influence dalam komunitas",
    potential_challenges: "Pastikan tidak terlalu dependent pada opinion orang lain - kembangkan independent judgment"
  },
  {
    combination_pattern: "FC",
    title: "Facilitating Conditions - Kondisi yang Memfasilitasi",
    description: "Anda memiliki akses yang memadai terhadap infrastruktur teknologi.",
    characteristics: "Anda memiliki akses yang memadai terhadap infrastruktur teknologi, pengetahuan, dan dukungan teknis yang diperlukan untuk menggunakan AI secara optimal. Anda dapat mengatasi hambatan teknis dan memiliki resource yang cukup untuk eksplorasi AI. Kekuatanmu adalah kemampuan troubleshooting dan adaptasi terhadap berbagai platform AI.",
    study_recommendations: "Optimalkan resource yang ada dengan membuat personal AI toolkit yang berisi berbagai aplikasi AI untuk kebutuhan berbeda: writing assistant, research helper, data analysis tools, dan presentation creator.",
    career_suggestions: "IT support, systems administration, technology consulting, atau infrastructure management",
    strengths: "Resource management, technical problem-solving, infrastructure optimization",
    potential_challenges: "Hindari over-reliance pada tools - pastikan memiliki backup plans dan tetap develop basic skills"
  },
  {
    combination_pattern: "HM",
    title: "Hedonic Motivation - Motivasi Hedonik",
    description: "Anda menikmati proses belajar dengan AI dan merasa terhibur saat menggunakan teknologi ini.",
    characteristics: "Anda menikmati proses belajar dengan AI dan merasa terhibur saat menggunakan teknologi ini. Pembelajaran menjadi lebih menarik dan interaktif, tidak monoton seperti metode konvensional. Kekuatanmu adalah kemampuan mempertahankan engagement dan motivation yang tinggi dalam pembelajaran karena faktor kenyamanan.",
    study_recommendations: "Variasikan penggunaan AI dengan mengeksplorasi fitur-fitur menarik seperti AI art generation untuk membuat visual aid, voice interaction untuk latihan presentasi, atau AI gaming untuk pembelajaran yang playful.",
    career_suggestions: "Creative industries, game design, educational content creation, atau entertainment technology",
    strengths: "High motivation, creativity, kemampuan membuat learning enjoyable",
    potential_challenges: "Jaga balance antara fun dan productivity - pastikan enjoyment tidak mengorbankan learning outcomes"
  },
  {
    combination_pattern: "PV",
    title: "Price Value - Nilai Harga",
    description: "Anda memiliki persepsi yang baik tentang cost-benefit ratio penggunaan AI dalam pembelajaran.",
    characteristics: "Anda memiliki persepsi yang baik tentang cost-benefit ratio penggunaan AI dalam pembelajaran. Anda menganggap investasi waktu, uang, dan effort untuk belajar AI sebanding dengan manfaat yang diperoleh. Kekuatanmu adalah kemampuan menilai value proposition dan membuat keputusan investasi yang bijak untuk pengembangan diri.",
    study_recommendations: "Maksimalkan ROI pembelajaran dengan fokus pada free AI tools berkualitas tinggi terlebih dahulu sebelum beralih ke premium services, dan gunakan AI untuk tugas-tugas yang memberikan impact terbesar pada produktivitas belajar.",
    career_suggestions: "Business analysis, investment consulting, cost optimization, atau financial planning",
    strengths: "Strategic thinking, cost-consciousness, value assessment skills",
    potential_challenges: "Jangan terlalu fokus pada cost sampai miss opportunities - kadang investment jangka panjang worth it"
  },
  {
    combination_pattern: "HT",
    title: "Habit - Kebiasaan",
    description: "Anda telah mengintegrasikan AI sebagai bagian natural dari routine belajar sehari-hari.",
    characteristics: "Anda telah mengintegrasikan AI sebagai bagian natural dari routine belajar sehari-hari. Penggunaan AI sudah menjadi automatic behavior yang tidak memerlukan conscious effort untuk diinisiasi. Kekuatanmu adalah konsistensi dan efisiensi dalam memanfaatkan AI sebagai learning companion yang terintegrasi seamlessly dalam workflow akademik.",
    study_recommendations: "Perkuat habit formation dengan membuat daily AI routine yang terstruktur: gunakan AI untuk morning briefing tentang jadwal belajar, research assistance saat mengerjakan tugas, dan evening reflection untuk evaluate progress harian.",
    career_suggestions: "Process improvement, workflow optimization, productivity consulting, atau operational excellence",
    strengths: "Consistency, discipline, ability to automate workflows",
    potential_challenges: "Hindari rigid routines yang tidak adaptable - tetap flexible untuk perubahan dan improvement"
  },
  {
    combination_pattern: "BI",
    title: "Behavioral Intention - Intensi Perilaku",
    description: "Anda memiliki komitmen jangka panjang yang kuat untuk terus mengembangkan keterampilan AI.",
    characteristics: "Anda memiliki komitmen jangka panjang yang kuat untuk terus mengembangkan keterampilan AI dan mengintegrasikannya dalam karir masa depan. Anda berencana untuk selalu mengikuti perkembangan terbaru dalam teknologi AI dan merekomendasikan penggunaannya kepada orang lain. Kekuatanmu adalah visi jangka panjang dan commitment untuk continuous learning dalam bidang AI.",
    study_recommendations: "Buat peta jalan pembelajaran AI jangka panjang yang mencakup pengembangan keterampilan secara bertahap: dari pengguna dasar ke pengguna tingkat lanjut, kemudian advokat AI, dan terakhir integrator AI dalam profesi masa depan.",
    career_suggestions: "Strategic planning, innovation management, technology evangelism, atau future-focused leadership roles",
    strengths: "Long-term vision, commitment to continuous learning, leadership potential",
    potential_challenges: "Balance antara future planning dan present action - jangan sampai terlalu fokus planning hingga kurang eksekusi"
  }
]

# Two Component Combinations
two_components = [
  {
    combination_pattern: "EEPE",
    title: "Tech Optimist",
    description: "Anda memiliki kepercayaan tinggi bahwa teknologi AI akan meningkatkan prestasi akademik dan merasa nyaman menggunakan berbagai aplikasi AI.",
    characteristics: "Anda memiliki kepercayaan tinggi bahwa teknologi AI akan meningkatkan prestasi akademik dan merasa nyaman menggunakan berbagai aplikasi AI tanpa kesulitan berarti. Sebagai Digital Native, Anda memiliki intuisi teknologi yang baik dan dapat dengan cepat mempelajari fitur-fitur baru. Kekuatan utama Anda terletak pada optimisme teknologi yang dikombinasikan dengan kemampuan adaptasi yang tinggi.",
    study_recommendations: "Manfaatkan kepercayaan diri teknologi Anda dengan memulai dari aplikasi AI sederhana seperti ChatGPT untuk tugas harian, kemudian secara bertahap eksplorasi tools yang lebih canggih seperti analisis data atau pembuatan konten kreatif.",
    career_suggestions: "Technology adoption specialist, digital transformation consultant, innovation manager",
    strengths: "Technology optimism, quick adaptation, progressive learning mindset",
    potential_challenges: "Jaga realistic expectations, pastikan tidak over-commit pada technology trends"
  },
  {
    combination_pattern: "PESI",
    title: "Social Achiever",
    description: "Anda percaya AI akan meningkatkan performa akademik dan memiliki dukungan kuat dari lingkungan sosial.",
    characteristics: "Anda percaya AI akan meningkatkan performa akademik dan memiliki dukungan kuat dari lingkungan sosial. Sebagai Community Champion, Anda menggabungkan keyakinan personal dengan pengaruh positif dari dosen, teman, dan institusi. Kemampuan Anda terletak pada harmonisasi antara ekspektasi personal dan ekspektasi sosial yang menciptakan motivasi kuat untuk mencapai kesuksesan.",
    study_recommendations: "Leverage kekuatan dukungan sosial dengan membentuk atau bergabung dalam kelompok belajar yang aktif menggunakan AI untuk kolaborasi akademik.",
    career_suggestions: "Team leadership, educational consulting, community management, collaborative technology roles",
    strengths: "Social influence, collaborative achievement, community building",
    potential_challenges: "Maintain individual initiative, don't become too dependent on group validation"
  },
  {
    combination_pattern: "HMHTPV",
    title: "Sustainable Joy Seeker",
    description: "Anda menggabungkan kesenangan dalam penggunaan AI, kesadaran nilai strategis, dan kemampuan untuk membangun kebiasaan yang berkelanjutan.",
    characteristics: "Anda menggabungkan kesenangan dalam penggunaan AI, kesadaran nilai strategis, dan kemampuan untuk membangun kebiasaan yang berkelanjutan. Sebagai Happy Investment Master, Anda dapat mempertahankan kepuasan jangka panjang sambil memastikan hasil optimal dari investasi teknologi.",
    study_recommendations: "Bangun strategi investasi yang memprioritaskan faktor kesenangan dan nilai jangka panjang, pertahankan kebiasaan yang mendukung kepuasan berkelanjutan dan optimalisasi hasil.",
    career_suggestions: "Sustainable technology consulting, user experience optimization, value-driven innovation",
    strengths: "Sustained motivation, value consciousness, habit formation, balanced approach",
    potential_challenges: "Ensure sustainability doesn't limit innovation, maintain growth mindset"
  }
]

# High-level Multi-Component Combinations
multi_components = [
  {
    combination_pattern: "EEPESI",
    title: "AI Ambassador",
    description: "Anda menggabungkan keyakinan tinggi terhadap performa AI, kemudahan penggunaan, dan dukungan sosial yang kuat.",
    characteristics: "Anda menggabungkan keyakinan tinggi terhadap performa AI, kemudahan penggunaan, dan dukungan sosial yang kuat. Sebagai Tech Community Leader, Anda memiliki trifekta ideal untuk kepemimpinan teknologi: kepercayaan diri pribadi, kemampuan teknis, dan pengaruh sosial.",
    study_recommendations: "Posisikan diri sebagai advokat teknologi dan mentor dalam komunitas, pimpin inisiatif yang mempromosikan adopsi AI yang efektif sambil memberikan dukungan kepada orang lain.",
    career_suggestions: "Technology evangelism, community leadership, training and development, digital transformation consulting",
    strengths: "Leadership potential, community influence, technical competence, advocacy skills",
    potential_challenges: "Balance advocacy with objectivity, avoid over-promoting without considering limitations"
  },
  {
    combination_pattern: "EEFCHMSI",
    title: "AI Learning Architect",
    description: "Anda menggabungkan ekspektasi performa, kemudahan penggunaan, dukungan sosial, akses sumber daya, dan kesenangan untuk desain pembelajaran komprehensif.",
    characteristics: "Anda menggabungkan ekspektasi performa, kemudahan penggunaan, dukungan sosial, akses sumber daya, dan kesenangan untuk desain pembelajaran komprehensif. Sebagai Digital Education Designer, Anda dapat menciptakan pengalaman pembelajaran inovatif yang mengoptimalkan berbagai faktor untuk hasil yang superior.",
    study_recommendations: "Rancang ekosistem pembelajaran komprehensif yang mengintegrasikan semua keunggulan untuk pengalaman pendidikan yang transformatif.",
    career_suggestions: "Educational technology design, learning experience architecture, innovation consulting, transformation leadership",
    strengths: "Holistic design thinking, comprehensive optimization, innovation leadership, transformative impact",
    potential_challenges: "Manage complexity, ensure scalability, maintain focus on core learning objectives"
  },
  {
    combination_pattern: "EEFCHMHTPVSI",
    title: "Digital Excellence Champion",
    description: "Anda menggabungkan hampir semua faktor optimal untuk penguasaan teknologi kecuali niat perilaku jangka panjang.",
    characteristics: "Anda menggabungkan hampir semua faktor optimal untuk penguasaan teknologi kecuali niat perilaku jangka panjang. Sebagai Digital Excellence Champion, Anda dapat mencapai hasil superior dalam konteks saat ini sambil memodelkan praktik terbaik untuk orang lain.",
    study_recommendations: "Manfaatkan kondisi yang hampir sempurna untuk mencapai dan menunjukkan tingkat penguasaan teknologi tertinggi, sambil mempertimbangkan pengembangan visi strategis jangka panjang.",
    career_suggestions: "Excellence consulting, best practice development, high-performance technology implementation, mastery coaching",
    strengths: "Near-perfect optimization, excellence modeling, comprehensive mastery, best practice development",
    potential_challenges: "Develop long-term strategic vision, ensure sustainable excellence, avoid perfection paralysis"
  },
  {
    combination_pattern: "BIEEFCHMHTPVSI",
    title: "AI Renaissance Master",
    description: "Anda memiliki profil sempurna dengan semua faktor optimal untuk penguasaan teknologi dan kepemimpinan.",
    characteristics: "Anda memiliki profil sempurna dengan semua faktor optimal untuk penguasaan teknologi dan kepemimpinan. Sebagai Digital Learning Virtuoso, Anda mewakili puncak adopsi teknologi dan dapat berfungsi sebagai model untuk orang lain. Kemampuan Anda adalah keunggulan komprehensif yang memungkinkan penguasaan pribadi dan kepemimpinan transformasional dalam kemajuan teknologi.",
    study_recommendations: "Manfaatkan profil yang luar biasa untuk menjadi figur transformasional dalam teknologi pendidikan, menciptakan dampak yang bertahan lama yang menguntungkan generasi saat ini dan masa depan.",
    career_suggestions: "Visionary leadership, institutional transformation, legacy building, generational impact creation, thought leadership",
    strengths: "Complete optimization, transformational leadership, legacy creation, generational impact, thought leadership",
    potential_challenges: "Manage overwhelming responsibility, ensure sustainable impact, balance multiple leadership roles"
  }
]

# Create descriptions
puts "Creating single component descriptions..."
single_components.each do |component|
  create_result_description(component[:combination_pattern], component.except(:combination_pattern))
end

puts "Creating two component combinations..."
two_components.each do |combination|
  create_result_description(combination[:combination_pattern], combination.except(:combination_pattern))
end

puts "Creating multi-component combinations..."
multi_components.each do |combination|
  create_result_description(combination[:combination_pattern], combination.except(:combination_pattern))
end

puts "Completed seeding AI Knowledge Result Descriptions!"
puts "Total descriptions created: #{AiKnowledgeResultDescription.count}"
