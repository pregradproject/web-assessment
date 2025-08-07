ActiveAdmin.register AiKnowledgeResultLevel do
  menu parent: 'AI Knowledge'
  permit_params :ai_knowledge_test_id, :user_id, :performance_expectancy_score,
                :effort_expectancy_score, :social_influence_score, :facilitating_conditions_score,
                :hedonic_motivation_score, :price_value_score, :habit_score, :behavioral_intention_score

  actions :index, :show

  index do
    selectable_column
    id_column
    column 'User' do |result|
      link_to result.user.name, admin_user_path(result.user) if result.user.present?
    end
    column 'Test' do |result|
      link_to "Test ##{result.ai_knowledge_test.id}", admin_ai_knowledge_test_path(result.ai_knowledge_test) if result.ai_knowledge_test.present?
    end
    column 'Total Score' do |result|
      result.total_score
    end
    column 'Dominant Styles' do |result|
      truncate(result.dominant_learning_styles.join(', '), length: 40)
    end
    column 'PE' do |result|
      result.performance_expectancy_score || 0
    end
    column 'EE' do |result|
      result.effort_expectancy_score || 0
    end
    column 'SI' do |result|
      result.social_influence_score || 0
    end
    column 'FC' do |result|
      result.facilitating_conditions_score || 0
    end
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_ai_knowledge_result_level_path(resource), class: 'view_link'
    end
  end

  filter :user, as: :select, collection: -> { User.joins(:ai_knowledge_result_level).distinct.order(:name) }
  filter :ai_knowledge_test, as: :select, collection: -> { AiKnowledgeTest.joins(:ai_knowledge_result_level).distinct.order(:created_at) }
  filter :performance_expectancy_score
  filter :effort_expectancy_score
  filter :social_influence_score
  filter :facilitating_conditions_score
  filter :hedonic_motivation_score
  filter :price_value_score
  filter :habit_score
  filter :behavioral_intention_score
  filter :created_at

  show do
    attributes_table do
      row :id
      row 'User' do |result|
        link_to result.user.name, admin_user_path(result.user) if result.user.present?
      end
      row 'Test' do |result|
        link_to "Test ##{result.ai_knowledge_test.id}", admin_ai_knowledge_test_path(result.ai_knowledge_test) if result.ai_knowledge_test.present?
      end
      row 'Total Score' do |result|
        result.total_score
      end
      row 'Dominant Learning Styles' do |result|
        result.dominant_learning_styles.join(', ')
      end
      row :created_at
      row :updated_at
    end

    panel 'Individual Scores' do
      attributes_table_for ai_knowledge_result_level do
        row 'Performance Expectancy (PE)' do |result|
          "#{result.performance_expectancy_score || 0} (#{result.percentage_for_category('PE')}%)"
        end
        row 'Effort Expectancy (EE)' do |result|
          "#{result.effort_expectancy_score || 0} (#{result.percentage_for_category('EE')}%)"
        end
        row 'Social Influence (SI)' do |result|
          "#{result.social_influence_score || 0} (#{result.percentage_for_category('SI')}%)"
        end
        row 'Facilitating Conditions (FC)' do |result|
          "#{result.facilitating_conditions_score || 0} (#{result.percentage_for_category('FC')}%)"
        end
        row 'Hedonic Motivation (HM)' do |result|
          "#{result.hedonic_motivation_score || 0} (#{result.percentage_for_category('HM')}%)"
        end
        row 'Price Value (PV)' do |result|
          "#{result.price_value_score || 0} (#{result.percentage_for_category('PV')}%)"
        end
        row 'Habit (HT)' do |result|
          "#{result.habit_score || 0} (#{result.percentage_for_category('HT')}%)"
        end
        row 'Behavioral Intention (BI)' do |result|
          "#{result.behavioral_intention_score || 0} (#{result.percentage_for_category('BI')}%)"
        end
      end
    end

    panel 'Score Analysis' do
      columns do
        column do
          attributes_table_for ai_knowledge_result_level do
            row 'Highest Score' do |result|
              scores = result.scores_as_hash
              max_score = scores.values.max
              highest_categories = scores.select { |_, score| score == max_score }.keys
              "#{max_score} (#{highest_categories.join(', ')})"
            end
            row 'Lowest Score' do |result|
              scores = result.scores_as_hash
              min_score = scores.values.min
              lowest_categories = scores.select { |_, score| score == min_score }.keys
              "#{min_score} (#{lowest_categories.join(', ')})"
            end
            row 'Score Range' do |result|
              scores = result.scores_as_hash.values
              "#{scores.min} - #{scores.max}"
            end
          end
        end

        column do
          attributes_table_for ai_knowledge_result_level do
            row 'Result Description' do |result|
              description = result.result_description
              if description
                link_to description.title, admin_ai_knowledge_result_description_path(description)
              else
                status_tag 'Not Found', class: 'error'
              end
            end
            row 'Style Type' do |result|
              description = result.result_description
              description&.style_type || 'Unknown'
            end
            row 'Multimodal' do |result|
              result.dominant_learning_styles.length > 1 ? 'Yes' : 'No'
            end
          end
        end
      end
    end

    panel 'Test Information' do
      if resource.ai_knowledge_test.present?
        attributes_table_for resource.ai_knowledge_test do
          row 'Question Set' do |test|
            link_to test.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(test.ai_knowledge_question_set) if test.ai_knowledge_question_set.present?
          end
          row :status do |test|
            status_tag test.status
          end
          row :started_at
          row :completed_at
          row 'Duration' do |test|
            if test.completed_at.present? && test.started_at.present?
              distance_of_time_in_words(test.started_at, test.completed_at)
            else
              '-'
            end
          end
          row 'Has Order' do |test|
            if test.order.present?
              link_to "Order ##{test.order.order_number}", admin_order_path(test.order)
            else
              status_tag('No', class: 'error')
            end
          end
        end
      end
    end

    active_admin_comments
  end

  # Scopes
  scope :all
  scope 'Performance Expectancy Dominant', :pe_dominant do |results|
    results.select do |result|
      scores = result.scores_as_hash
      max_score = scores.values.max
      scores['PE'] == max_score
    end
  end
  scope 'Effort Expectancy Dominant', :ee_dominant do |results|
    results.select do |result|
      scores = result.scores_as_hash
      max_score = scores.values.max
      scores['EE'] == max_score
    end
  end
  scope 'Social Influence Dominant', :si_dominant do |results|
    results.select do |result|
      scores = result.scores_as_hash
      max_score = scores.values.max
      scores['SI'] == max_score
    end
  end
  scope 'Facilitating Conditions Dominant', :fc_dominant do |results|
    results.select do |result|
      scores = result.scores_as_hash
      max_score = scores.values.max
      scores['FC'] == max_score
    end
  end
  scope 'Multimodal', :multimodal do |results|
    results.select { |result| result.dominant_learning_styles.length > 1 }
  end

  # Configuration
  config.per_page = 20
  config.sort_order = 'created_at_desc'

  # Custom collection action for analytics
  collection_action :analytics, method: :get do
    @total_results = AiKnowledgeResultLevel.count
    @category_stats = {}

    %w[PE EE SI FC HM PV HT BI].each do |code|
      @category_stats[code] = {
        name: AiKnowledgeCategory.find_by(code: code)&.name || code,
        avg_score: AiKnowledgeResultLevel.average("#{code.downcase == 'pe' ? 'performance_expectancy' : code.downcase == 'ee' ? 'effort_expectancy' : code.downcase == 'si' ? 'social_influence' : code.downcase == 'fc' ? 'facilitating_conditions' : code.downcase == 'hm' ? 'hedonic_motivation' : code.downcase == 'pv' ? 'price_value' : code.downcase == 'ht' ? 'habit' : 'behavioral_intention'}_score")&.round(2) || 0
      }
    end

    render plain: "Analytics: #{@total_results} total results. Category averages: #{@category_stats.map { |k, v| "#{k}: #{v[:avg_score]}" }.join(', ')}"
  end

  action_item :analytics, only: :index do
    link_to 'View Analytics', analytics_admin_ai_knowledge_result_levels_path
  end
end
