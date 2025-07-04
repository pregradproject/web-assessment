module Certificates
  class CertificateTemplateService < ApplicationService
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
    end

    def prepare_basic_variables
      @certificate_id = certificate_id
      @current_date = formatted_current_date
      @user_name = @user.name
      @birth_date = formatted_birth_date
      @test_date = formatted_test_date
    end

    def prepare_score_variables
      @visual_score = @vark_result.visual_score
      @aural_score = @vark_result.aural_score
      @read_score = @vark_result.read_score
      @kinesthetic_score = @vark_result.kinesthetic_score
    end

    def prepare_chart_variables
      @scores = scores_array
      @percentages = percentages_array
      @learning_style_description = formatted_learning_style_description
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
        @vark_result.visual_score,
        @vark_result.aural_score,
        @vark_result.read_score,
        @vark_result.kinesthetic_score
      ]
    end

    def percentages_array
      total = scores_array.sum
      return [ 0, 0, 0, 0 ] if total.zero?

      scores_array.map { |score| ((score.to_f / total) * 100).round }
    end

    def formatted_learning_style_description
      category = get_dominant_category
      return default_description unless category&.description.present?

      description = category.description.strip
      paragraphs = description.split("\n\n")
      formatted_paragraphs = paragraphs.map { |p| "<p>#{p.strip}</p>" }
      title = "<h3>#{category.name} Learning Style</h3>"

      "#{title}\n#{formatted_paragraphs.join("\n")}"
    end

    def get_dominant_category
      dominant_style = @vark_result.dominant_learning_styles.first
      return nil unless dominant_style

      category_code = case dominant_style
      when 'Visual' then 'V'
      when 'Aural' then 'A'
      when 'Read/Write' then 'R'
      when 'Kinesthetic' then 'K'
      else 'R'
      end

      VarkCategory.find_by(code: category_code)
    end

    def default_description
      '<h3>Learning Style</h3><p>Your learning style analysis is available.</p>'
    end

    def failure_result(error_message)
      { success: false, error: error_message }
    end
  end
end
