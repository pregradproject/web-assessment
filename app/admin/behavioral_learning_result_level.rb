ActiveAdmin.register BehavioralLearningResultLevel do
  menu parent: 'Behavioral Learning'
  permit_params :behavioral_learning_test_id, :user_id, :total_score, :total_questions, :average_score,
                :level_label, :level_message, :threshold_min, :threshold_max

  index do
    selectable_column
    id_column
    column 'Test' do |result|
      link_to "Test ##{result.behavioral_learning_test.id}", admin_behavioral_learning_test_path(result.behavioral_learning_test) if result.behavioral_learning_test.present?
    end
    column 'User' do |result|
      link_to result.user.name, admin_user_path(result.user) if result.user.present?
    end
    column :total_score
    column :total_questions
    column :average_score
    column :level_label
    column 'Categories Breakdown' do |result|
      breakdown = result.category_breakdown
      breakdown.map { |code, score| "#{code}: #{score}" }.join(', ')
    end
    column :created_at
    actions
  end

  filter :user, as: :select, collection: -> { User.order(:name) }
  filter :behavioral_learning_test, as: :select, collection: -> { BehavioralLearningTest.joins(:user).order('users.name') }
  filter :level_label
  filter :average_score
  filter :created_at

  form do |f|
    f.inputs 'Result Level Details' do
      f.input :behavioral_learning_test, as: :select, collection: BehavioralLearningTest.includes(:user).order('users.name')
      f.input :user, as: :select, collection: User.order(:name)
      f.input :total_score
      f.input :total_questions
      f.input :average_score
      f.input :level_label
      f.input :level_message, as: :text
      f.input :threshold_min
      f.input :threshold_max
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row 'Test' do |result|
        link_to "Test ##{result.behavioral_learning_test.id}", admin_behavioral_learning_test_path(result.behavioral_learning_test) if result.behavioral_learning_test.present?
      end
      row 'User' do |result|
        link_to result.user.name, admin_user_path(result.user) if result.user.present?
      end
      row :total_score
      row :total_questions
      row :average_score
      row :level_label
      row :level_message
      row :threshold_min
      row :threshold_max
      row :created_at
      row :updated_at
    end

    panel 'Category Breakdown' do
      category_data = resource.category_breakdown.map do |code, total_score|
        {
          code: code,
          total_score: total_score,
          average_score: resource.category_average(code),
          name: BehavioralLearningCategory.find_by(code: code)&.name
        }
      end

      table_for category_data do
        column 'Category Code' do |category|
          category[:code]
        end
        column 'Total Score' do |category|
          category[:total_score]
        end
        column 'Average Score' do |category|
          category[:average_score]
        end
        column 'Category Name' do |category|
          category[:name]
        end
      end
    end

    panel 'Performance Analysis' do
      attributes_table do
        row 'Strongest Categories' do |result|
          result.strongest_categories.join(', ')
        end
        row 'Weakest Categories' do |result|
          result.weakest_categories.join(', ')
        end
        row 'Performance Level' do |result|
          case result.average_score
          when 0..2.0
            status_tag 'Needs Improvement', class: 'error'
          when 2.01..3.5
            status_tag 'Developing', class: 'orange'
          when 3.51..4.5
            status_tag 'Proficient', class: 'ok'
          when 4.51..5.0
            status_tag 'Excellent', class: 'yes'
          else
            status_tag 'Unknown', class: 'no'
          end
        end
      end
    end

    active_admin_comments
  end
end
