class BehavioralLearningGoogleSheetsImportService < ApplicationService
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
      create_question_set_category(question_set, category)

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
    # Get the latest version and increment it properly
    latest_question_set = BehavioralLearningQuestionSet.order(version: :desc).first
    if latest_question_set
      # Extract numeric version from strings like "v1.0" or just use the number
      latest_version = latest_question_set.version.to_s.gsub(/[^\d]/, '').to_i
      latest_version = 1 if latest_version == 0
      new_version = "v#{latest_version + 1}.0"
    else
      new_version = 'v1.0'
    end

    BehavioralLearningQuestionSet.create!(
      version: new_version,
      name: "Upload (#{Date.current.strftime('%Y-%m-%d')})",
      active: false,
      time_limit: @time_limit.to_i
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
    category = row['Category']&.strip&.upcase
    question = row['Question']&.strip

    # Skip invalid rows
    return nil if category.blank? || question.blank?

    # Validate category - Behavioral Learning uses OBS, SRL, GOL, OUT categories
    valid_categories = %w[OBS SRL GOL OUT]
    unless valid_categories.include?(category)
      raise "Invalid category '#{category}'. Must be one of: #{valid_categories.join(', ')}"
    end

    {
      category: category,
      question: question
    }
  end

  def convert_to_csv_url(sheets_url)
    # Extract the spreadsheet ID from the URL
    match = sheets_url.match(/\/spreadsheets\/d\/([a-zA-Z0-9\-_]+)/)
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
    BehavioralLearningCategory.find_by(code: category_code) ||
      raise("Category with code '#{category_code}' not found in database")
  end

  def create_question_set_category(question_set, category)
    BehavioralLearningQuestionSetCategory.create!(
      behavioral_learning_question_set: question_set,
      behavioral_learning_category: category
    )
  end

  def create_question(question_set, category, question_data)
    BehavioralLearningQuestion.create!(
      behavioral_learning_question_set: question_set,
      behavioral_learning_category: category,
      body: question_data[:question]
    )
  end
end
