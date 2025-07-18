require 'ostruct'

module AiKnowledge
  class ResultDescriptionMatcher < ApplicationService
    attr_reader :dominant_learning_styles, :result_level

    def initialize(dominant_learning_styles, result_level = nil)
      @dominant_learning_styles = dominant_learning_styles
      @result_level = result_level
    end

    def call
      return default_description if dominant_learning_styles.blank?

      # Find exact match first
      description = find_exact_match
      return description if description.present?

      # Try fallback strategies
      description = find_fallback_match
      return description if description.present?

      # Return default if no match found
      default_description
    end

    private

    def find_exact_match
      AiKnowledgeResultDescription.find_by_dominant_styles(dominant_learning_styles)
    end

    def find_fallback_match
      codes = extract_codes

      find_by_combinations(codes) || find_by_single_code(codes)
    end

    def extract_codes
      dominant_learning_styles.map { |style| AiKnowledgeResultDescription.style_name_to_code(style) }.compact
    end

    def find_by_combinations(codes)
      (codes.length - 1).downto(1) do |size|
        codes.combination(size).each do |combo|
          description = find_description(combo)
          return description if description.present?
        end
      end
      nil
    end

    def find_by_single_code(codes)
      codes.each do |code|
        description = AiKnowledgeResultDescription.active.find_by(combination_pattern: code)
        return description if description.present?
      end
      nil
    end

    def find_description(combo)
      pattern = AiKnowledgeResultDescription.normalize_pattern(combo)
      AiKnowledgeResultDescription.active.find_by(combination_pattern: pattern)
    end

    def default_description
      # Return a generic description object
      OpenStruct.new(
        title: 'Balanced AI Knowledge Profile',
        description: 'You demonstrate a balanced approach to AI adoption with strengths across multiple dimensions.',
        characteristics: 'Flexible AI learning approach with varied competencies across all eight components.',
        study_recommendations: 'Continue developing all AI knowledge areas while leveraging your strongest components.',
        strengths: 'Adaptability to different AI tools and learning environments.',
        potential_challenges: 'May need to prioritize specific AI areas based on career goals and interests.',
        career_suggestions: 'Suitable for diverse AI-enhanced careers requiring broad technological competency.',
        style_type: 'Balanced Mixed',
        learning_styles: dominant_learning_styles || [],
        multimodal?: (dominant_learning_styles&.length || 0) > 1
      )
    end

    def calculate_score_percentages
      return {} unless result_level.present?

      total_score = result_level.total_score
      return {} if total_score.zero?

      {
        performance_expectancy: (result_level.performance_expectancy_score / total_score * 100).round(1),
        effort_expectancy: (result_level.effort_expectancy_score / total_score * 100).round(1),
        social_influence: (result_level.social_influence_score / total_score * 100).round(1),
        facilitating_conditions: (result_level.facilitating_conditions_score / total_score * 100).round(1),
        hedonic_motivation: (result_level.hedonic_motivation_score / total_score * 100).round(1),
        price_value: (result_level.price_value_score / total_score * 100).round(1),
        habit: (result_level.habit_score / total_score * 100).round(1),
        behavioral_intention: (result_level.behavioral_intention_score / total_score * 100).round(1)
      }
    end

    def assess_score_distribution
      return 'balanced' unless result_level.present?
      return 'balanced' if max_score.zero?

      classify_score_ratio(score_ratio)
    end

    def scores
      [
        result_level.performance_expectancy_score,
        result_level.effort_expectancy_score,
        result_level.social_influence_score,
        result_level.facilitating_conditions_score,
        result_level.hedonic_motivation_score,
        result_level.price_value_score,
        result_level.habit_score,
        result_level.behavioral_intention_score
      ]
    end

    def max_score
      scores.max
    end

    def min_score
      scores.min
    end

    def score_ratio
      min_score.to_f / max_score
    end

    def classify_score_ratio(ratio)
      case ratio
      when 0.8..1.0 then 'highly_balanced'
      when 0.6..0.79 then 'moderately_balanced'
      when 0.4..0.59 then 'somewhat_unbalanced'
      else 'highly_specialized'
      end
    end
  end
end
