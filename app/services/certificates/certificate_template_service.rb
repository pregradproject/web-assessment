module Certificates
  class CertificateTemplateService < ApplicationService
    include ActionView::Helpers::AssetUrlHelper

    def initialize(order)
      @order = order
      @test = order.testable
      @user = order.user
      @test_type = determine_test_type
      @result = get_result_level
    end

    def call
      return failure_result('Test not found') unless @test
      return failure_result('Result not found') unless @result
      return failure_result('User not found') unless @user

      prepare_template_variables
      html_content = render_template

      { success: true, html: html_content }
    rescue StandardError => e
      failure_result("Template processing failed: #{e.message}")
    end

    private

    def prepare_template_variables
      prepare_basic_variables
      prepare_score_variables
      prepare_chart_variables
      prepare_signature_variables
    end

    def prepare_basic_variables
      @certificate_id = certificate_id
      @current_date = formatted_current_date
      @user_name = @user.name
      @birth_date = formatted_birth_date
      @test_date = formatted_test_date
    end

    def prepare_score_variables
      if @test_type == :vark
        prepare_vark_scores
      elsif @test_type == :ai_knowledge
        prepare_ai_knowledge_scores
      end
    end

    def prepare_vark_scores
      @visual_score = format_score(@result.visual_score)
      @aural_score = format_score(@result.aural_score)
      @read_score = format_score(@result.read_score)
      @kinesthetic_score = format_score(@result.kinesthetic_score)
    end

    def prepare_ai_knowledge_scores
      @performance_expectancy_score = format_score(@result.performance_expectancy_score)
      @effort_expectancy_score = format_score(@result.effort_expectancy_score)
      @social_influence_score = format_score(@result.social_influence_score)
      @facilitating_conditions_score = format_score(@result.facilitating_conditions_score)
      @hedonic_motivation_score = format_score(@result.hedonic_motivation_score)
      @price_value_score = format_score(@result.price_value_score)
      @habit_score = format_score(@result.habit_score)
      @behavioral_intention_score = format_score(@result.behavioral_intention_score)
    end

    def prepare_chart_variables
      @scores = scores_array
      @percentages = percentages_array
      @result_data = get_result_data
      @dominant_styles = get_dominant_styles_info
      @learning_style_title = get_learning_style_title
      @description = @result_data[:description]
      @study_recommendations = @result_data[:study_recommendations]
      @background_image_path = "file://#{Rails.root}/public/background.jpg"
    end

    def prepare_signature_variables
      signature = Signature.active.first
      if signature&.signature_image&.attached?
        load_signature(signature)
      else
        load_default_signature
      end
    end

    def load_signature(sig)
      @signature_name         = sig.name
      @signature_title        = sig.department
      @has_signature_image    = true
      @signature_image_path   = get_signature_image_path(sig)
    end

    def load_default_signature
      @signature_name         = 'John Doe'
      @signature_title        = 'Dean of Malang University'
      @has_signature_image    = false
      @signature_image_path   = nil
    end

    def render_template
      template_name = @test_type == :vark ? 'vark.html.erb' : 'ai_knowledge.html.erb'
      template_path = Rails.root.join('app', 'views', 'certificate', template_name)
      template_content = File.read(template_path)
      ERB.new(template_content).result(binding)
    end

    def certificate_id
      @order.order_number.gsub('ORD-', 'CERT-')
    end

    def formatted_current_date
      Date.current.strftime('%-d %B %Y')
    end

    def formatted_birth_date
      @user.birthday&.strftime('%Y-%m-%d') || 'Not specified'
    end

    def formatted_test_date
      @test.completed_at&.strftime('%Y-%m-%d') || Date.current.strftime('%Y-%m-%d')
    end

    def scores_array
      if @test_type == :vark
        [
          format_score(@result.visual_score),
          format_score(@result.aural_score),
          format_score(@result.read_score),
          format_score(@result.kinesthetic_score)
        ]
      else # ai_knowledge
        [
          format_score(@result.performance_expectancy_score),
          format_score(@result.effort_expectancy_score),
          format_score(@result.social_influence_score),
          format_score(@result.facilitating_conditions_score),
          format_score(@result.hedonic_motivation_score),
          format_score(@result.price_value_score),
          format_score(@result.habit_score),
          format_score(@result.behavioral_intention_score)
        ]
      end
    end

    def percentages_array
      if @test_type == :vark
        raw_scores = [
          @result.visual_score || 0,
          @result.aural_score || 0,
          @result.read_score || 0,
          @result.kinesthetic_score || 0
        ]
        calculate_percentages(raw_scores, 4)
      else # ai_knowledge
        raw_scores = [
          @result.performance_expectancy_score || 0,
          @result.effort_expectancy_score || 0,
          @result.social_influence_score || 0,
          @result.facilitating_conditions_score || 0,
          @result.hedonic_motivation_score || 0,
          @result.price_value_score || 0,
          @result.habit_score || 0,
          @result.behavioral_intention_score || 0
        ]
        calculate_percentages(raw_scores, 8)
      end
    end

    def calculate_percentages(raw_scores, count)
      total = raw_scores.sum
      return Array.new(count, 0) if total.zero?

      raw_scores.map { |score| ((score.to_f / total) * 100).round }
    end

    def get_result_data
      @result.detailed_result_data
    end

    def get_learning_style_title
      dominant_styles = @result.dominant_learning_styles
      return 'Learning Style' if dominant_styles.empty?

      if @test_type == :vark
        build_vark_style_title(dominant_styles)
      else
        build_ai_knowledge_style_title(dominant_styles)
      end
    end

    def build_vark_style_title(dominant_styles)
      code_part = map_vark_styles_to_codes(dominant_styles).join('')
      name_part = map_vark_styles_to_display_names(dominant_styles).join(' - ')
      "#{name_part} (#{code_part})"
    end

    def build_ai_knowledge_style_title(dominant_styles)
      code_part = map_ai_styles_to_codes(dominant_styles).join('')
      name_part = map_ai_styles_to_display_names(dominant_styles).join(' - ')
      "#{name_part} (#{code_part})"
    end

    def map_vark_styles_to_codes(styles)
      styles.map do |style|
        case style
        when 'Visual' then 'V'
        when 'Auditory' then 'A'
        when 'Read/Write' then 'R'
        when 'Kinesthetic' then 'K'
        end
      end.compact
    end

    def map_vark_styles_to_display_names(styles)
      styles.map do |style|
        case style
        when 'Read/Write' then 'Reading'
        else style
        end
      end
    end

    AI_STYLE_CODES = {
      'Performance Expectancy' => 'PE',
      'Effort Expectancy' => 'EE',
      'Social Influence' => 'SI',
      'Facilitating Conditions' => 'FC',
      'Hedonic Motivation' => 'HM',
      'Price Value' => 'PV',
      'Habit' => 'HT',
      'Behavioral Intention' => 'BI'
    }.freeze

    def map_ai_styles_to_codes(styles)
      styles.map { |style| AI_STYLE_CODES[style] }.compact
    end

    AI_STYLE_DISPLAY_NAMES = {
      'Performance Expectancy' => 'Performance',
      'Effort Expectancy' => 'Effort',
      'Social Influence' => 'Social',
      'Facilitating Conditions' => 'Facilitating',
      'Hedonic Motivation' => 'Hedonic',
      'Price Value' => 'Price',
      'Habit' => 'Habit',
      'Behavioral Intention' => 'Behavioral'
    }.freeze

    def map_ai_styles_to_display_names(styles)
      styles.map { |style| AI_STYLE_DISPLAY_NAMES[style] || style }
    end

    def get_dominant_styles_info
      dominant_styles = @result.dominant_learning_styles
      return [ default_style_info ] if dominant_styles.empty?

      style_map = @test_type == :vark ? vark_style_map : ai_knowledge_style_map

      dominant_styles.map do |style_name|
        style = style_map[style_name]
        next unless style

        {
          name: style[:name],
          score: style[:score].call,
          color: style[:color],
          label: get_score_label(style_name)
        }
      end.compact
    end

    def get_score_label(style_name)
      if @test_type == :vark
        get_vark_score_label(style_name)
      else
        get_ai_knowledge_score_label(style_name)
      end
    end

    def get_vark_score_label(style_name)
      case style_name
      when 'Visual' then 'Visual Score'
      when 'Auditory' then 'Auditory Score'
      when 'Read/Write' then 'Reading Score'
      when 'Kinesthetic' then 'Kinesthetic Score'
      else 'Score'
      end
    end

    AI_SCORE_LABELS = {
      'Performance Expectancy' => 'Performance Score',
      'Effort Expectancy' => 'Effort Score',
      'Social Influence' => 'Social Score',
      'Facilitating Conditions' => 'Facilitating Score',
      'Hedonic Motivation' => 'Hedonic Score',
      'Price Value' => 'Price Score',
      'Habit' => 'Habit Score',
      'Behavioral Intention' => 'Behavioral Score'
    }.freeze

    def get_ai_knowledge_score_label(style_name)
      AI_SCORE_LABELS[style_name] || 'Score'
    end

    def get_style_class(style_name)
      case style_name
      when 'Visual' then 'visual'
      when 'Auditory' then 'auditory'
      when 'Reading' then 'reading'
      when 'Kinesthetic' then 'kinesthetic'
      else 'reading'
      end
    end


    def vark_style_map
      {
        'Visual' => {
          name: 'Visual',
          score: -> { format_score(@result.visual_score) },
          color: '#8979FF',
          chart_colors: %w[#8979FF #d3d3d3 #d3d3d3 #d3d3d3]
        },
        'Auditory' => {
          name: 'Auditory',
          score: -> { format_score(@result.aural_score) },
          color: '#FF928A',
          chart_colors: %w[#d3d3d3 #FF928A #d3d3d3 #d3d3d3]
        },
        'Read/Write' => {
          name: 'Reading',
          score: -> { format_score(@result.read_score) },
          color: '#3CC3DF',
          chart_colors: %w[#d3d3d3 #d3d3d3 #3CC3DF #d3d3d3]
        },
        'Kinesthetic' => {
          name: 'Kinesthetic',
          score: -> { format_score(@result.kinesthetic_score) },
          color: '#FFAE4C',
          chart_colors: %w[#d3d3d3 #d3d3d3 #d3d3d3 #FFAE4C]
        }
      }
    end

    def ai_knowledge_style_map
      {
        'Performance Expectancy' => {
          name: 'Performance',
          score: -> { format_score(@result.performance_expectancy_score) },
          color: '#8979FF'
        },
        'Effort Expectancy' => {
          name: 'Effort',
          score: -> { format_score(@result.effort_expectancy_score) },
          color: '#FF928A'
        },
        'Social Influence' => {
          name: 'Social',
          score: -> { format_score(@result.social_influence_score) },
          color: '#3CC3DF'
        },
        'Facilitating Conditions' => {
          name: 'Facilitating',
          score: -> { format_score(@result.facilitating_conditions_score) },
          color: '#FFAE4C'
        },
        'Hedonic Motivation' => {
          name: 'Hedonic',
          score: -> { format_score(@result.hedonic_motivation_score) },
          color: '#9B59B6'
        },
        'Price Value' => {
          name: 'Price',
          score: -> { format_score(@result.price_value_score) },
          color: '#E67E22'
        },
        'Habit' => {
          name: 'Habit',
          score: -> { format_score(@result.habit_score) },
          color: '#2ECC71'
        },
        'Behavioral Intention' => {
          name: 'Behavioral',
          score: -> { format_score(@result.behavioral_intention_score) },
          color: '#E74C3C'
        }
      }
    end

    def default_style_info
      if @test_type == :vark
        {
          name: 'Reading',
          score: format_score(@result.read_score),
          color: '#3CC3DF',
          label: 'Reading Score'
        }
      else
        {
          name: 'Performance',
          score: format_score(@result.performance_expectancy_score),
          color: '#8979FF',
          label: 'Performance Score'
        }
      end
    end

    def format_score(score)
      return '0.0' if score.nil?

      '%.1f' % score.to_f
    end

    def default_description
      '<h3>Learning Style</h3><p>Your learning style analysis is available.</p>'
    end

    def get_signature_image_path(signature)
      # Create a temporary file for the signature image
      temp_file = Tempfile.new([ 'signature', '.png' ])
      temp_file.binmode
      temp_file.write(signature.signature_image.download)
      temp_file.close
      "file://#{temp_file.path}"
    end

    def failure_result(error_message)
      { success: false, error: error_message }
    end

    def determine_test_type
      case @test.class.name
      when 'VarkTest'
        :vark
      when 'AiKnowledgeTest'
        :ai_knowledge
      else
        :unknown
      end
    end

    def get_result_level
      case @test_type
      when :vark
        @test.vark_result_level
      when :ai_knowledge
        @test.ai_knowledge_result_level
      else
        nil
      end
    end
  end
end
