module BehavioralLearning
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
      object.behavioral_learning_questions.map do |question|
        {
          id: question.id,
          body: question.body,
          category: {
            id: question.behavioral_learning_category.id,
            code: question.behavioral_learning_category.code,
            name: question.behavioral_learning_category.name
          }
        }
      end
    end
  end
end
