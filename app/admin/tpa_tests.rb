ActiveAdmin.register TpaTest do
  menu parent: 'TPA Management', priority: 4
  permit_params :user_id, :tpa_question_set_id, :status

  index do
    selectable_column
    id_column
    column :user do |test|
      test.user.email if test.user
    end
    column :question_set do |test|
      test.tpa_question_set.name
    end
    column :status
    column :started_at
    column :completed_at
    column :completion_percentage do |test|
      "#{test.completion_percentage}%"
    end
    column :time_remaining do |test|
      if test.in_progress?
        minutes = test.time_remaining / 60
        "#{minutes} min"
      else
        '-'
      end
    end
    column :order_status do |test|
      if test.order
        status_tag test.order.status.humanize,
                   class: test.order.paid? ? 'ok' : (test.order.pending? ? 'warning' : 'error')
      else
        'No Order'
      end
    end
    column :certificate_status do |test|
      if test.order&.certificate_pdf&.attached?
        status_tag 'Generated', class: 'ok'
      elsif test.order&.certificate_status == 'generating'
        status_tag 'Generating', class: 'warning'
      elsif test.order&.certificate_status == 'generation_failed'
        status_tag 'Failed', class: 'error'
      elsif test.order&.paid?
        status_tag 'Ready', class: 'warning'
      else
        '-'
      end
    end
    column :created_at
    actions
  end

  filter :user, as: :select, collection: -> { User.all.map { |u| [ u.email, u.id ] } }
  filter :tpa_question_set, as: :select, collection: -> { TpaQuestionSet.all.map { |qs| [ qs.name, qs.id ] } }
  filter :status, as: :select, collection: TpaTest.statuses.keys.map { |s| [ s.humanize, s ] }
  filter :started_at
  filter :completed_at
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.all.map { |u| [ u.email, u.id ] }
      f.input :tpa_question_set, as: :select, collection: TpaQuestionSet.all.map { |qs| [ qs.name, qs.id ] }
      f.input :status, as: :select, collection: TpaTest.statuses.keys.map { |s| [ s.humanize, s ] }
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :user do |test|
        link_to test.user.email, admin_user_path(test.user) if test.user
      end
      row :question_set do |test|
        link_to test.tpa_question_set.name, admin_tpa_question_set_path(test.tpa_question_set)
      end
      row :status do |test|
        status_tag test.status.humanize,
                   class: test.completed? ? 'ok' : (test.in_progress? ? 'warning' : 'error')
      end
      row :started_at
      row :completed_at
      row :completion_percentage do |test|
        "#{test.completion_percentage}%"
      end
      row :time_remaining do |test|
        if test.in_progress?
          minutes = test.time_remaining / 60
          "#{minutes} minutes"
        else
          'N/A'
        end
      end
      row :created_at
      row :updated_at
    end

    panel 'Test Progress' do
      if tpa_test.tpa_answers.any?
        answered = tpa_test.tpa_answers.count
        total = tpa_test.questions.count
        correct = tpa_test.tpa_answers.correct_answers.count

        table_for [ { metric: 'Questions Answered', value: "#{answered} / #{total}" },
                    { metric: 'Correct Answers', value: correct },
                    { metric: 'Current Score', value: total > 0 ? "#{((correct.to_f / total) * 100).round(2)}%" : '0%' } ] do
          column :metric
          column :value
        end
      else
        div 'No answers submitted yet'
      end
    end

    panel 'Submitted Answers' do
      if tpa_test.tpa_answers.any?
        table_for tpa_test.tpa_answers.includes(tpa_question: :tpa_category) do
          column :question do |answer|
            truncate(answer.tpa_question.question_text, length: 80)
          end
          column :category do |answer|
            answer.tpa_question.tpa_category.name
          end
          column :selected_option
          column :correct_answer do |answer|
            answer.tpa_question.correct_answer
          end
          column :is_correct do |answer|
            status_tag answer.is_correct? ? 'Correct' : 'Incorrect',
                       class: answer.is_correct? ? 'ok' : 'error'
          end
          column :answered_at
        end
      else
        div 'No answers submitted yet'
      end
    end

    panel 'Test Results' do
      if tpa_test.tpa_result_level
        result = tpa_test.tpa_result_level
        attributes_table_for result do
          row :total_score
          row :total_questions
          row :average_score do |r|
            "#{r.average_score}%"
          end
          row :level_label do |r|
            status_tag r.level_label, class: 'ok'
          end
          row :level_message
          row :verbal_score
          row :quantitative_score
          row :analytic_score
          row :spatial_score
        end
      else
        div 'Results not calculated yet'
      end
    end

    panel 'Order & Certificate Information' do
      if tpa_test.order
        order = tpa_test.order
        attributes_table_for order do
          row :order_number
          row :status do |o|
            status_tag o.status.humanize,
                       class: o.paid? ? 'ok' : (o.pending? ? 'warning' : 'error')
          end
          row :amount do |o|
            number_to_currency(o.amount, unit: 'Rp ', delimiter: '.', precision: 0)
          end
          row :certificate_status do |o|
            status_tag o.certificate_status.humanize,
                       class: o.generated? ? 'ok' : (o.generating? ? 'warning' : 'error')
          end
          row :certificate_generated_at
          row :created_at
        end

        if order.certificate_pdf.attached?
          div class: 'certificate-download' do
            link_to 'Download Certificate', rails_blob_path(order.certificate_pdf, disposition: 'attachment'),
                    class: 'button',
                    target: '_blank'
          end
        elsif order.paid? && !order.certificate_pdf.attached?
          div class: 'certificate-generation' do
            span 'Certificate ready for generation'
          end
        end
      else
        div 'No order created yet'
      end
    end
  end

  action_item :calculate_results, only: :show do
    if tpa_test.completed? && !tpa_test.tpa_result_level
      link_to 'Calculate Results', calculate_results_admin_tpa_test_path(tpa_test), method: :post
    end
  end

  action_item :create_order, only: :show do
    if tpa_test.completed? && !tpa_test.order
      link_to 'Create Order', create_order_admin_tpa_test_path(tpa_test), method: :post
    end
  end

  action_item :generate_certificate, only: :show do
    if tpa_test.order&.paid? && !tpa_test.order.certificate_pdf.attached?
      link_to 'Generate Certificate', generate_certificate_admin_tpa_test_path(tpa_test), method: :post
    end
  end

  member_action :calculate_results, method: :post do
    test = TpaTest.find(params[:id])
    if test.completed? && !test.tpa_result_level
      Tpa::ResultCalculationServices.new(test).call
      redirect_to admin_tpa_test_path(test), notice: 'Results calculated successfully!'
    else
      redirect_to admin_tpa_test_path(test), alert: 'Cannot calculate results for this test.'
    end
  end

  member_action :create_order, method: :post do
    test = TpaTest.find(params[:id])
    if test.completed? && !test.order
      Orders::CreateOrderServices.call(test)
      redirect_to admin_tpa_test_path(test), notice: 'Order created successfully!'
    else
      redirect_to admin_tpa_test_path(test), alert: 'Cannot create order for this test.'
    end
  end

  member_action :generate_certificate, method: :post do
    test = TpaTest.find(params[:id])
    if test.order&.paid? && !test.order.certificate_pdf.attached?
      GenerateCertificateJob.perform_later(test.order.id)
      redirect_to admin_tpa_test_path(test), notice: 'Certificate generation started!'
    else
      redirect_to admin_tpa_test_path(test), alert: 'Cannot generate certificate for this test.'
    end
  end
end
