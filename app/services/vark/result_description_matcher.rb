require 'ostruct'

module Vark
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
      VarkResultDescription.find_by_dominant_styles(dominant_learning_styles)
    end

    def find_fallback_match
      codes = extract_codes

      find_by_combinations(codes) || find_by_single_code(codes)
    end

    private

    def extract_codes
      dominant_learning_styles.map { |style| VarkResultDescription.style_name_to_code(style) }.compact
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
        description = VarkResultDescription.active.find_by(combination_pattern: code)
        return description if description.present?
      end
      nil
    end

    def find_description(combo)
      pattern = VarkResultDescription.normalize_pattern(combo)
      VarkResultDescription.active.find_by(combination_pattern: pattern)
    end

    def default_description
      # Return a generic description object
      OpenStruct.new(
        title: 'Mixed Learning Style',
        description: 'You demonstrate a balanced approach to learning with preferences across multiple learning styles.',
        characteristics: 'Flexible learning approach with varied preferences.',
        study_recommendations: 'Use a combination of visual, auditory, reading, and kinesthetic learning methods.',
        strengths: 'Adaptability to different learning environments and teaching methods.',
        potential_challenges: 'May need to experiment to find the most effective learning methods for specific subjects.',
        career_suggestions: 'Suitable for careers that require diverse skill sets and adaptability.',
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
        visual: (result_level.visual_score / total_score * 100).round(1),
        auditory: (result_level.aural_score / total_score * 100).round(1),
        read_write: (result_level.read_score / total_score * 100).round(1),
        kinesthetic: (result_level.kinesthetic_score / total_score * 100).round(1)
      }
    end

    def assess_score_distribution
      return 'balanced' unless result_level.present?
      return 'balanced' if max_score.zero?

      classify_score_ratio(score_ratio)
    end

    def scores
      [
        result_level.visual_score,
        result_level.aural_score,
        result_level.read_score,
        result_level.kinesthetic_score
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
