module Certificates
  class CertificateTemplateService < ApplicationService
    include ActionView::Helpers::AssetUrlHelper

    def initialize(order)
      @order = order
      @vark_test = order.testable
      @user = order.user
      @vark_result = @vark_test.vark_result_level
    end

    def call
      return failure_result('VarkTest not found') unless @vark_test
      return failure_result('VarkResultLevel not found') unless @vark_result
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
      @visual_score = format_score(@vark_result.visual_score)
      @aural_score = format_score(@vark_result.aural_score)
      @read_score = format_score(@vark_result.read_score)
      @kinesthetic_score = format_score(@vark_result.kinesthetic_score)
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
      template_path = Rails.root.join('app', 'views', 'certificate', 'vark.html.erb')
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
      @vark_test.completed_at&.strftime('%Y-%m-%d') || Date.current.strftime('%Y-%m-%d')
    end

    def scores_array
      [
        format_score(@vark_result.visual_score),
        format_score(@vark_result.aural_score),
        format_score(@vark_result.read_score),
        format_score(@vark_result.kinesthetic_score)
      ]
    end

    def percentages_array
      raw_scores = [
        @vark_result.visual_score || 0,
        @vark_result.aural_score || 0,
        @vark_result.read_score || 0,
        @vark_result.kinesthetic_score || 0
      ]
      total = raw_scores.sum
      return [ 0, 0, 0, 0 ] if total.zero?

      raw_scores.map { |score| ((score.to_f / total) * 100).round }
    end

    def get_result_data
      @vark_result.detailed_result_data
    end

    def get_learning_style_title
      dominant_styles = @vark_result.dominant_learning_styles
      return 'Learning Style' if dominant_styles.empty?

      code_part = map_styles_to_codes(dominant_styles).join('')
      name_part = map_styles_to_display_names(dominant_styles).join(' - ')

      "#{name_part} (#{code_part})"
    end

    def map_styles_to_codes(styles)
      styles.map do |style|
        case style
        when 'Visual' then 'V'
        when 'Auditory' then 'A'
        when 'Read/Write' then 'R'
        when 'Kinesthetic' then 'K'
        end
      end.compact
    end

    def map_styles_to_display_names(styles)
      styles.map do |style|
        case style
        when 'Read/Write' then 'Reading'
        else style
        end
      end
    end

    def get_dominant_styles_info
      dominant_styles = @vark_result.dominant_learning_styles
      return [ default_style_info ] if dominant_styles.empty?

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
      case style_name
      when 'Visual' then 'Visual Score'
      when 'Auditory' then 'Auditory Score'
      when 'Read/Write' then 'Reading Score'
      when 'Kinesthetic' then 'Kinesthetic Score'
      else 'Score'
      end
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


    def style_map
      {
        'Visual' => {
          name: 'Visual',
          score: -> { format_score(@vark_result.visual_score) },
          color: '#8979FF',
          chart_colors: %w[#8979FF #d3d3d3 #d3d3d3 #d3d3d3]
        },
        'Auditory' => {
          name: 'Auditory',
          score: -> { format_score(@vark_result.aural_score) },
          color: '#FF928A',
          chart_colors: %w[#d3d3d3 #FF928A #d3d3d3 #d3d3d3]
        },
        'Read/Write' => {
          name: 'Reading',
          score: -> { format_score(@vark_result.read_score) },
          color: '#3CC3DF',
          chart_colors: %w[#d3d3d3 #d3d3d3 #3CC3DF #d3d3d3]
        },
        'Kinesthetic' => {
          name: 'Kinesthetic',
          score: -> { format_score(@vark_result.kinesthetic_score) },
          color: '#FFAE4C',
          chart_colors: %w[#d3d3d3 #d3d3d3 #d3d3d3 #FFAE4C]
        }
      }
    end

    def default_style_info
      {
        name: 'Reading',
        score: format_score(@vark_result.read_score),
        color: '#3CC3DF',
        label: 'Reading Score'
      }
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
  end
end
