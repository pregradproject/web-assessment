
ActiveAdmin.register VarkResultLevel do
  menu parent: 'Vark'
  permit_params :vark_question_set_id, :vark_category_id, :min_score, :max_score,
                :visual_score, :aural_score, :read_score, :kinesthetic_score

  index do
    selectable_column
    id_column
    column :vark_question_set
    column :vark_category
    column :min_score
    column :max_score
    actions
  end

  filter :vark_question_set
  filter :vark_category
  filter :min_score
  filter :max_score

  form do |f|
    f.inputs 'Result Level' do
      f.input :vark_question_set
      f.input :vark_category
      f.input :min_score, input_html: { step: 0.1, placeholder: '0.0' }
      f.input :max_score, input_html: { step: 0.1, placeholder: '0.0' }
      f.input :visual_score, input_html: { step: 0.1, placeholder: '0.0' }
      f.input :aural_score, input_html: { step: 0.1, placeholder: '0.0' }
      f.input :read_score, input_html: { step: 0.1, placeholder: '0.0' }
      f.input :kinesthetic_score, input_html: { step: 0.1, placeholder: '0.0' }
    end
    f.actions
  end
end
