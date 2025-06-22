module Vark
  class ActiveQuestionSetSerializer < ApplicationSerializer
    attributes(
      :id,
      :version,
      :name,
      :active,
      :created_at,
      :updated_at,
      :time_limit
    )

    attribute :questions do |object|
      object.vark_questions.map do |question|
        {
          id: question.id,
          body: question.body,
          max_weight: question.max_weight,
          category: {
            id: question.vark_category.id,
            code: question.vark_category.code,
            name: question.vark_category.name
          }
        }
      end
    end
  end
end
