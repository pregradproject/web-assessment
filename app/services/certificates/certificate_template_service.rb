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
      case @test_type
      when :vark then prepare_vark_scores
      when :ai_knowledge then prepare_ai_knowledge_scores
      when :behavioral_learning then prepare_behavioral_learning_scores
      when :comprehensive_assessment then prepare_comprehensive_assessment_scores
      when :tpa then prepare_tpa_scores
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

    def prepare_behavioral_learning_scores
      @obs_score = format_score(@result.category_average('OBS'))
      @srl_score = format_score(@result.category_average('SRL'))
      @gol_score = format_score(@result.category_average('GOL'))
      @out_score = format_score(@result.category_average('OUT'))
    end

    def prepare_comprehensive_assessment_scores
      @cf_score = format_score(@result.category_average('CF'))
      @resilience_score = format_score(@result.category_average('R'))
      @e_score = format_score(@result.category_average('E'))
      @ag_score = format_score(@result.category_average('AG'))
      @ma_score = format_score(@result.category_average('MA'))
    end

    def prepare_tpa_scores
      @verbal_score = format_score(@result.verbal_score)
      @quantitative_score = format_score(@result.quantitative_score)
      @analytic_score = format_score(@result.analytic_score)
      @spatial_score = format_score(@result.spatial_score)
    end

    def prepare_chart_variables
      @scores = scores_array
      @percentages = percentages_array
      @result_data = get_result_data
      @dominant_styles = get_dominant_styles_info
      @learning_style_title = get_learning_style_title
      @assessment_title = @learning_style_title # For comprehensive assessment compatibility
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
      template_name = get_template_name
      template_path = Rails.root.join('app', 'views', 'certificate', template_name)
      template_content = File.read(template_path)
      ERB.new(template_content).result(binding)
    end

    def get_template_name
      template_mapping = {
        vark: 'vark.html.erb',
        behavioral_learning: 'behavioral_learning.html.erb',
        comprehensive_assessment: 'comprehensive_assessment.html.erb',
        tpa: 'tpa.html.erb'
      }
      template_mapping[@test_type] || 'ai_knowledge.html.erb'
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
      score_builder_mapping = {
        vark: -> { build_vark_scores_array },
        behavioral_learning: -> { build_behavioral_learning_scores_array },
        comprehensive_assessment: -> { build_comprehensive_assessment_scores_array },
        tpa: -> { build_tpa_scores_array }
      }
      score_builder_mapping[@test_type]&.call || build_ai_knowledge_scores_array
    end

    def percentages_array
      percentage_mapping = {
        vark: -> { calculate_vark_percentages },
        behavioral_learning: -> { calculate_behavioral_learning_percentages },
        comprehensive_assessment: -> { calculate_comprehensive_assessment_percentages },
        tpa: -> { calculate_tpa_percentages }
      }
      percentage_mapping[@test_type]&.call || calculate_ai_knowledge_percentages
    end

    private

    def calculate_vark_percentages
      raw_scores = [
        @result.visual_score || 0,
        @result.aural_score || 0,
        @result.read_score || 0,
        @result.kinesthetic_score || 0
      ]
      calculate_percentages(raw_scores, 4)
    end

    def calculate_behavioral_learning_percentages
      raw_scores = [
        @result.category_average('OBS') || 0,
        @result.category_average('SRL') || 0,
        @result.category_average('GOL') || 0,
        @result.category_average('OUT') || 0
      ]
      calculate_percentages(raw_scores, 4)
    end

    def calculate_comprehensive_assessment_percentages
      raw_scores = [
        @result.category_average('CF') || 0,
        @result.category_average('R') || 0,
        @result.category_average('E') || 0,
        @result.category_average('AG') || 0,
        @result.category_average('MA') || 0
      ]
      calculate_percentages(raw_scores, 5)
    end

    def calculate_tpa_percentages
      raw_scores = [
        @result.verbal_score || 0,
        @result.quantitative_score || 0,
        @result.analytic_score || 0,
        @result.spatial_score || 0
      ]
      calculate_percentages(raw_scores, 4)
    end

    def build_vark_scores_array
      [
        format_score(@result.visual_score),
        format_score(@result.aural_score),
        format_score(@result.read_score),
        format_score(@result.kinesthetic_score)
      ]
    end

    def build_behavioral_learning_scores_array
      [
        format_score(@result.category_average('OBS')),
        format_score(@result.category_average('SRL')),
        format_score(@result.category_average('GOL')),
        format_score(@result.category_average('OUT'))
      ]
    end

    def build_comprehensive_assessment_scores_array
      [
        format_score(@result.category_average('CF')),
        format_score(@result.category_average('R')),
        format_score(@result.category_average('E')),
        format_score(@result.category_average('AG')),
        format_score(@result.category_average('MA'))
      ]
    end

    def build_tpa_scores_array
      [
        format_score(@result.verbal_score),
        format_score(@result.quantitative_score),
        format_score(@result.analytic_score),
        format_score(@result.spatial_score)
      ]
    end

    def build_ai_knowledge_scores_array
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

    def calculate_ai_knowledge_percentages
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

    def calculate_percentages(raw_scores, count)
      total = raw_scores.sum
      return Array.new(count, 0) if total.zero?

      raw_scores.map { |score| ((score.to_f / total) * 100).round }
    end

    def get_result_data
      @result.detailed_result_data
    end

    def get_learning_style_title
      title_mapping = {
        behavioral_learning: -> { build_behavioral_learning_style_title },
        vark: -> { build_vark_learning_style_title },
        comprehensive_assessment: -> { build_comprehensive_assessment_style_title },
        tpa: -> { build_tpa_learning_style_title }
      }
      title_mapping[@test_type]&.call || build_ai_knowledge_learning_style_title
    end

    def build_behavioral_learning_style_title
      strongest_categories = @result.strongest_categories
      return 'Behavioral Learning Style' if strongest_categories.empty?

      strongest_categories.join(' - ')
    end

    def build_vark_learning_style_title
      dominant_styles = @result.dominant_learning_styles
      return 'Learning Style' if dominant_styles.empty?

      build_vark_style_title(dominant_styles)
    end

    def build_ai_knowledge_learning_style_title
      dominant_styles = @result.dominant_learning_styles
      return 'Learning Style' if dominant_styles.empty?

      build_ai_knowledge_style_title(dominant_styles)
    end

    def build_comprehensive_assessment_style_title
      strongest_categories = @result.strongest_categories
      return 'Comprehensive Assessment Profile' if strongest_categories.empty?

      strongest_categories.join(' - ')
    end

    def build_tpa_learning_style_title
      strongest_categories = @result.strongest_categories
      return 'TPA Assessment Profile' if strongest_categories.empty?

      strongest_categories.map { |cat| "#{cat.humanize} Reasoning" }.join(' - ')
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
      case @test_type
      when :behavioral_learning
        build_behavioral_learning_styles_info
      else
        build_standard_styles_info
      end
    end

    def build_behavioral_learning_styles_info
      strongest_categories = @result.strongest_categories
      return [ default_style_info ] if strongest_categories.empty?

      behavioral_style_map = behavioral_learning_style_map
      strongest_categories.map do |category_name|
        build_behavioral_style_info(category_name, behavioral_style_map)
      end.compact
    end

    def build_behavioral_style_info(category_name, style_map)
      category_code = map_category_name_to_code(category_name)
      return unless category_code

      style = style_map[category_code]
      return unless style

      {
        name: style[:name],
        score: style[:score].call,
        color: style[:color],
        label: get_score_label(category_name)
      }
    end

    def build_standard_styles_info
      dominant_styles = @result.dominant_learning_styles
      return [ default_style_info ] if dominant_styles.empty?

      style_map = @test_type == :vark ? vark_style_map : ai_knowledge_style_map
      dominant_styles.map do |style_name|
        build_standard_style_info(style_name, style_map)
      end.compact
    end

    def build_standard_style_info(style_name, style_map)
      style = style_map[style_name]
      return unless style

      {
        name: style[:name],
        score: style[:score].call,
        color: style[:color],
        label: get_score_label(style_name)
      }
    end

    def get_score_label(style_name)
      if @test_type == :vark
        get_vark_score_label(style_name)
      elsif @test_type == :behavioral_learning
        get_behavioral_learning_score_label(style_name)
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

    BEHAVIORAL_LEARNING_SCORE_LABELS = {
      'Observation' => 'Observation Score',
      'Self-Regulation' => 'Self-Regulation Score',
      'Goal Setting' => 'Goal Setting Score',
      'Learning Outcomes' => 'Learning Outcomes Score'
    }.freeze

    def get_behavioral_learning_score_label(style_name)
      BEHAVIORAL_LEARNING_SCORE_LABELS[style_name] || 'Score'
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

    def behavioral_learning_style_map
      {
        'OBS' => {
          name: 'Observation',
          score: -> { format_score(@result.category_average('OBS')) },
          color: '#8979FF'
        },
        'SRL' => {
          name: 'Self-Regulation',
          score: -> { format_score(@result.category_average('SRL')) },
          color: '#FF928A'
        },
        'GOL' => {
          name: 'Goal Setting',
          score: -> { format_score(@result.category_average('GOL')) },
          color: '#3CC3DF'
        },
        'OUT' => {
          name: 'Learning Outcomes',
          score: -> { format_score(@result.category_average('OUT')) },
          color: '#FFAE4C'
        }
      }
    end

    def map_category_name_to_code(category_name)
      case category_name&.downcase
      when 'observation' then 'OBS'
      when 'self-regulation' then 'SRL'
      when 'goal setting' then 'GOL'
      when 'learning outcomes' then 'OUT'
      else nil
      end
    end

    def default_style_info
      if @test_type == :vark
        {
          name: 'Reading',
          score: format_score(@result.read_score),
          color: '#3CC3DF',
          label: 'Reading Score'
        }
      elsif @test_type == :behavioral_learning
        {
          name: 'Observation',
          score: format_score(@result.category_average('OBS')),
          color: '#8979FF',
          label: 'Observation Score'
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
      test_type_mapping[@test.class.name] || :unknown
    end

    def get_result_level
      mapping = result_level_mapping[@test_type]
      mapping&.call
    end

    def test_type_mapping
      {
        'VarkTest' => :vark,
        'AiKnowledgeTest' => :ai_knowledge,
        'BehavioralLearningTest' => :behavioral_learning,
        'ComprehensiveAssessmentTest' => :comprehensive_assessment,
        'TpaTest' => :tpa
      }
    end

    def result_level_mapping
      {
        vark: -> { @test.vark_result_level },
        ai_knowledge: -> { @test.ai_knowledge_result_level },
        behavioral_learning: -> { @test.behavioral_learning_result_level },
        comprehensive_assessment: -> { @test.comprehensive_assessment_result_level },
        tpa: -> { @test.tpa_result_level }
      }
    end
  end
end
