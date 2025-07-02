require 'base64'
require 'ostruct'

module Certificates
  class TemplateService < ApplicationService
    def initialize(order)
      @order = order
      @vark_test = order.testable
      @user = order.user
      @vark_result = @vark_test.vark_result_level
    end

    def call
      render_certificate
    end

    def render_certificate
      ApplicationController.new.render_to_string(
        template: 'certificates/vark_certificate',
        layout: 'certificates/pdf_layout',
        locals: certificate_data
      )
    end

    private

    def certificate_data
      {
        user: @user,
        vark_test: @vark_test,
        order: @order,
        vark_result: @vark_result,
        scores: calculate_scores,
        primary_learning_style: calculate_primary_learning_style,
        learning_style_description: get_learning_style_description,
        signature: get_signature,
        signature_image_data: get_signature_image_data,
        certificate_date: @order.certificate_generated_at || Time.current,
        test_completion_date: @vark_test.completed_at&.strftime('%Y-%m-%d')
      }
    end

    def calculate_scores
      return default_scores unless @vark_result

      total_score = @vark_result.visual_score + @vark_result.aural_score +
                   @vark_result.read_score + @vark_result.kinesthetic_score

      {
        visual: {
          score: @vark_result.visual_score,
          percentage: calculate_percentage(@vark_result.visual_score, total_score)
        },
        aural: {
          score: @vark_result.aural_score,
          percentage: calculate_percentage(@vark_result.aural_score, total_score)
        },
        read: {
          score: @vark_result.read_score,
          percentage: calculate_percentage(@vark_result.read_score, total_score)
        },
        kinesthetic: {
          score: @vark_result.kinesthetic_score,
          percentage: calculate_percentage(@vark_result.kinesthetic_score, total_score)
        },
        total: total_score
      }
    end

    def calculate_percentage(score, total)
      return 0 if total.zero?
      ((score.to_f / total.to_f) * 100).round(1)
    end

    def calculate_primary_learning_style
      scores = calculate_scores
      max_score = [
        scores[:visual][:score],
        scores[:aural][:score],
        scores[:read][:score],
        scores[:kinesthetic][:score]
      ].max

      case max_score
      when scores[:visual][:score]
        { style: 'Visual', code: 'V', color: '#60A5FA' }
      when scores[:aural][:score]
        { style: 'Aural/Auditory', code: 'A', color: '#FB7185' }
      when scores[:read][:score]
        { style: 'Read/Write', code: 'R', color: '#34D399' }
      when scores[:kinesthetic][:score]
        { style: 'Kinesthetic', code: 'K', color: '#FBBF24' }
      else
        { style: 'Multimodal', code: 'M', color: '#8B5CF6' }
      end
    rescue => e
      Rails.logger.error "Error calculating primary learning style: #{e.message}"
      { style: 'Visual', code: 'V', color: '#60A5FA' }
    end

    def get_learning_style_description
      primary_style = calculate_primary_learning_style

      descriptions = {
        'Visual' => 'Prefer words and text as an information obtaining method. They like presentation style, by text or writing. Students with the tendency of reading prefer printed word and text as a method to gain information. They like glossy, textbooks, lecture notes, or circulation. These students like to arrange lecture notes into sketch form, paraphrase classroom notes, and study multiple choice exam questions. Besides that, students are note takers. They study better through note taken from lecture or from difficult reading materials.',
        'Aural/Auditory' => 'Learn best through hearing and listening. They prefer verbal instruction, discussions, and audio materials. These learners benefit from reading aloud, participating in group discussions, and using mnemonic devices.',
        'Read/Write' => 'Prefer words and text as an information obtaining method. They like presentation style, by text or writing. Students with this tendency prefer printed word and text as a method to gain information.',
        'Kinesthetic' => 'Learn through hands-on experience and physical activity. They prefer practical applications, experiments, and real-world examples. These learners need to move around and engage physically with their learning materials.'
      }

      descriptions[primary_style[:style]] || 'You have a multimodal learning preference, effectively using multiple learning styles.'
    end

    def get_signature
      # Get the first active signature, or create a default one
      active_signature = Signature.where(status: :active).first

      if active_signature&.signature_image&.attached?
        active_signature
      else
        default_signature
      end
    end

    def default_signature
      OpenStruct.new(
        name: 'Director of Assessment',
        department: 'Learning Sciences Department',
        signature_image: nil
      )
    end

    def get_signature_image_data
      signature = get_signature

      if signature.respond_to?(:signature_image) && signature.signature_image&.attached?
        begin
          Rails.logger.info "Processing signature image for: #{signature.name}"

          # Validate image type
          content_type = signature.signature_image.content_type
          unless [ 'image/png', 'image/jpeg', 'image/jpg', 'image/gif' ].include?(content_type)
            Rails.logger.warn "Unsupported signature image type: #{content_type}"
            return nil
          end

          image_data = signature.signature_image.download
          encoded_image = Base64.strict_encode64(image_data)
          data_uri = "data:#{content_type};base64,#{encoded_image}"

          Rails.logger.info "Successfully processed signature image (#{image_data.size} bytes)"
          data_uri
        rescue => e
          Rails.logger.error "Failed to process signature image: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          nil
        end
      else
        Rails.logger.info 'No signature image available, using fallback signature line'
        nil
      end
    end

    def default_scores
      {
        visual: { score: 0, percentage: 0 },
        aural: { score: 0, percentage: 0 },
        read: { score: 0, percentage: 0 },
        kinesthetic: { score: 0, percentage: 0 },
        total: 0
      }
    end
  end
end
