class TpaGoogleSheetsImportService < ApplicationService
  include ActiveModel::Model

  attr_accessor :google_sheets_url

  def initialize(google_sheets_url, time_limit)
    @google_sheets_url = google_sheets_url
    @time_limit = time_limit
    @errors = []
  end

  def import!
    validate_url!

    ActiveRecord::Base.transaction do
      question_set = create_question_set!
      process_questions(question_set)
      question_set
    end
  rescue => e
    raise "Import failed: #{e.message}"
  end

  private

  def process_questions(question_set)
    rows = parse_google_sheets
    questions_by_category = group_questions_by_category(rows)
    create_categories_and_questions(question_set, questions_by_category)
  end

  def create_categories_and_questions(question_set, questions_by_category)
    questions_by_category.each do |category_code, questions|
      category = find_or_create_category(category_code)

      questions.each do |question_data|
        create_question(question_set, category, question_data)
      end
    end
  end

  def validate_url!
    unless google_sheets_url.present? && google_sheets_url.include?('docs.google.com/spreadsheets')
      raise 'Invalid Google Sheets URL'
    end
  end

  def create_question_set!
    highest_version = TpaQuestionSet.maximum(:version) || 0

    TpaQuestionSet.create!(
      name: "Upload (#{Date.current.strftime('%Y-%m-%d')})",
      version: highest_version + 1,
      active: false,
      time_limit: @time_limit
    )
  end

  def parse_google_sheets
    csv_url = convert_to_csv_url(google_sheets_url)
    csv_data = open_csv_from_url(csv_url)
    rows = extract_valid_rows(csv_data)

    if rows.empty?
      raise 'No valid questions found in the Google Sheet'
    end

    rows
  end

  def extract_valid_rows(csv_data)
    rows = []

    CSV.parse(csv_data, headers: true, skip_blanks: true) do |row|
      next if row.to_h.values.all?(&:blank?)

      row_data = extract_and_validate_row_data(row)
      rows << row_data if row_data
    end

    rows
  end

  def extract_and_validate_row_data(row)
    data = extract_row_data(row)
    return nil if missing_required_fields?(data)

    validate_category(data[:category])
    validate_correct_answer(data[:correct_answer])
    validate_difficulty_level(data[:difficulty_level])

    data
  end

  def extract_row_data(row)
    {
      category: row['Category']&.strip&.upcase,
      question_text: row['Question']&.strip,
      option_a: row['Option A']&.strip,
      option_b: row['Option B']&.strip,
      option_c: row['Option C']&.strip,
      option_d: row['Option D']&.strip,
      option_e: row['Option E']&.strip,
      correct_answer: row['Correct Answer']&.strip&.upcase,
      explanation: row['Explanation']&.strip,
      difficulty_level: (row['Difficulty Level']&.strip&.to_i || 3)
    }
  end

  def missing_required_fields?(data)
    data.values_at(:category, :question_text, :option_a, :option_b,
                   :option_c, :option_d, :option_e, :correct_answer,
                   :explanation).any?(&:blank?)
  end

  def validate_category(category)
    unless %w[V Q A S].include?(category)
      raise "Invalid category '#{category}'. Must be one of: V, Q, A, S"
    end
  end

  def validate_correct_answer(correct_answer)
    unless %w[A B C D E].include?(correct_answer)
      raise "Invalid correct answer '#{correct_answer}'. Must be one of: A, B, C, D, E"
    end
  end

  def validate_difficulty_level(difficulty_level)
    unless difficulty_level.between?(1, 5)
      raise "Invalid difficulty level '#{difficulty_level}'. Must be between 1 and 5"
    end
  end

  def convert_to_csv_url(sheets_url)
    # Extract the spreadsheet ID from the URL
    match = sheets_url.match(/\/spreadsheets\/d\/([a-zA-Z0-9-_]+)/)
    unless match
      raise 'Could not extract spreadsheet ID from URL'
    end

    spreadsheet_id = match[1]
    "https://docs.google.com/spreadsheets/d/#{spreadsheet_id}/export?format=csv"
  end

  def open_csv_from_url(csv_url)
    require 'open-uri'

    begin
      URI.open(csv_url, &:read)
    rescue => e
      raise "Could not access Google Sheets. Make sure the sheet is publicly accessible. Error: #{e.message}"
    end
  end

  def group_questions_by_category(rows)
    rows.group_by { |row| row[:category] }
  end

  def find_or_create_category(category_code)
    TpaCategory.find_by(code: category_code) ||
      TpaCategory.create!(
        code: category_code,
        name: "Category #{category_code}",
        description: "Imported category #{category_code}"
      )
  end

  def create_question(question_set, category, question_data)
    TpaQuestion.create!(
      tpa_question_set: question_set,
      tpa_category: category,
      question_text: question_data[:question_text],
      option_a: question_data[:option_a],
      option_b: question_data[:option_b],
      option_c: question_data[:option_c],
      option_d: question_data[:option_d],
      option_e: question_data[:option_e],
      correct_answer: question_data[:correct_answer],
      explanation: question_data[:explanation],
      difficulty_level: question_data[:difficulty_level]
    )
  end
end
