class UpdateBehavioralLearningCategories < ActiveRecord::Migration[8.0]
  def up
    # Update category codes and names
    # M (Motivation) -> GOL (Goal Setting)
    BehavioralLearningCategory.where(code: 'M').update_all(
      code: 'GOL',
      name: 'Goal Setting',
      description: 'Measures internal drive and goal-setting behavior'
    )

    # A (Engagement) -> OBS (Observation)
    BehavioralLearningCategory.where(code: 'A').update_all(
      code: 'OBS',
      name: 'Observation',
      description: 'Measures ability to observe and analyze learning situations'
    )

    # H (Habits) -> OUT (Learning Outcomes)
    BehavioralLearningCategory.where(code: 'H').update_all(
      code: 'OUT',
      name: 'Learning Outcomes',
      description: 'Measures achievement of learning objectives and results'
    )

    # R (Self-Regulation) -> SRL (Self-Regulation)
    BehavioralLearningCategory.where(code: 'R').update_all(
      code: 'SRL',
      name: 'Self-Regulation',
      description: 'Measures ability to control and manage behavior'
    )
  end

  def down
    # Revert category codes and names
    BehavioralLearningCategory.where(code: 'GOL').update_all(
      code: 'M',
      name: 'Motivation',
      description: 'Measures internal drive and goal-setting behavior'
    )

    BehavioralLearningCategory.where(code: 'OBS').update_all(
      code: 'A',
      name: 'Engagement',
      description: 'Measures level of involvement and participation'
    )

    BehavioralLearningCategory.where(code: 'OUT').update_all(
      code: 'H',
      name: 'Habits',
      description: 'Measures consistency and routine formation'
    )

    BehavioralLearningCategory.where(code: 'SRL').update_all(
      code: 'R',
      name: 'Self-Regulation',
      description: 'Measures ability to control and manage behavior'
    )
  end
end
