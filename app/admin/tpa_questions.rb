ActiveAdmin.register TpaQuestion do
  menu parent: 'TPA Management', priority: 3
  permit_params :tpa_category_id, :tpa_question_set_id, :question_text,
                :option_a, :option_b, :option_c, :option_d, :option_e,
                :correct_answer, :explanation, :difficulty_level, :image

  index do
    selectable_column
    id_column
    column :category do |question|
      question.tpa_category.name
    end
    column :question_set do |question|
      question.tpa_question_set.name
    end
    column :question_text do |question|
      truncate(question.question_text, length: 60)
    end
    column :difficulty_level
    column :correct_answer
    column :image do |question|
      question.image.attached? ? 'Yes' : 'No'
    end
    column :created_at
    actions
  end

  filter :tpa_category, as: :select, collection: -> { TpaCategory.all.map { |c| [ c.name, c.id ] } }
  filter :tpa_question_set, as: :select, collection: -> { TpaQuestionSet.all.map { |qs| [ qs.name, qs.id ] } }
  filter :difficulty_level
  filter :correct_answer, as: :select, collection: %w[A B C D E]
  filter :created_at

  form do |f|
    f.inputs do
      f.input :tpa_category, as: :select, collection: TpaCategory.all.map { |c| [ c.name, c.id ] }
      f.input :tpa_question_set, as: :select, collection: TpaQuestionSet.all.map { |qs| [ qs.name, qs.id ] }
      f.input :question_text, as: :text
      f.input :option_a
      f.input :option_b
      f.input :option_c
      f.input :option_d
      f.input :option_e
      f.input :correct_answer, as: :select, collection: %w[A B C D E]
      f.input :explanation, as: :text
      f.input :difficulty_level, as: :select, collection: (1..5).to_a
      f.input :image, as: :file, hint: 'Optional image for the question'
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :category do |question|
        question.tpa_category.name
      end
      row :question_set do |question|
        question.tpa_question_set.name
      end
      row :question_text
      row :option_a
      row :option_b
      row :option_c
      row :option_d
      row :option_e
      row :correct_answer do |question|
        status_tag question.correct_answer, :ok
      end
      row :explanation
      row :difficulty_level
      row :image do |question|
        if question.image.attached?
          image_tag question.image, style: 'max-width: 300px; max-height: 200px;'
        else
          'No image attached'
        end
      end
      row :created_at
      row :updated_at
    end

    panel 'Answer Statistics' do
      if tpa_question.tpa_answers.any?
        total_answers = tpa_question.tpa_answers.count
        correct_answers = tpa_question.tpa_answers.correct_answers.count
        accuracy = ((correct_answers.to_f / total_answers) * 100).round(2)

        table_for [ { metric: 'Total Answers', value: total_answers },
                    { metric: 'Correct Answers', value: correct_answers },
                    { metric: 'Accuracy Rate', value: "#{accuracy}%" } ] do
          column :metric
          column :value
        end
      else
        div 'No answers submitted yet'
      end
    end
  end
end
