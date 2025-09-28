class Api::V1::TpaTestsController < ApiController
  before_action :set_tpa_test, only: [ :show, :submit_answers, :results ]

  # GET /api/v1/user/tpa_tests
  def index
    @tpa_tests = current_user.tpa_tests.includes(:tpa_question_set).recent

    tests_data = @tpa_tests.map do |test|
      Tpa::TestSerializer.new(test).to_h
    end

    json_response({ data: tests_data }, :ok, false)
  end

  # POST /api/v1/user/tpa_tests/order
  def create_order
    @order = Tpa::CreateOrderServices.new(current_user, params[:coupon_code]).call

    order_data = Orders::CreateOrderSerializer.new(@order).to_h

    json_response({ data: order_data }, :created, false)
  end

  # POST /api/v1/user/tpa_tests
  def create
    create_tpa_test
  rescue ActiveRecord::RecordNotFound
    raise CkvExceptions::NotFoundError, 'Question set not found'
  rescue ActiveRecord::RecordInvalid => e
    raise CkvExceptions::UnprocessableEntityError, e.record.errors.full_messages
  end

  # GET /api/v1/user/tpa_tests/active_question_set
  def active_question_set
    @question_set = TpaQuestionSet.active_set.first

    raise CkvExceptions::NotFoundError, 'No active question set found' unless @question_set

    question_set_data = Tpa::ActiveQuestionSetSerializer.new(@question_set).to_h

    json_response({ data: question_set_data }, :ok, false)
  end

  # GET /api/v1/user/tpa_tests/:id
  def show
    test_data = Tpa::TestSerializer.new(@tpa_test, include_questions: true).to_h

    json_response({ data: test_data }, :ok, false)
  end

  # POST /api/v1/user/tpa_tests/:id/submit_answers
  def submit_answers
    validator = Tpa::SubmitAnswerValidator.new(@tpa_test, submit_answers_params[:answers])
    raise CkvExceptions::UnprocessableEntityError, validator.errors.full_messages unless validator.valid?

    unless @tpa_test.in_progress?
      raise CkvExceptions::ForbiddenError, 'Cannot submit answers to a completed or expired test'
    end

    result = Tpa::SubmitAnswersServices.new(@tpa_test, submit_answers_params[:answers]).call

    json_response({ data: result }, :ok, false)
  end

  # GET /api/v1/user/tpa_tests/:id/results
  def results
    validator = Tpa::TestResultsValidator.new(@tpa_test)
    raise CkvExceptions::UnprocessableEntityError, validator.errors.full_messages unless validator.valid?

    @result_level = Tpa::ResultCalculationServices.new(@tpa_test).call

    results_data = Tpa::TestResultsSerializer.new(@result_level).to_h

    json_response({ data: results_data }, :ok, false)
  end

  private

  def set_tpa_test
    @tpa_test = current_user.tpa_tests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise CkvExceptions::NotFoundError, 'Test not found'
  end

  def tpa_test_params
    params.permit(:tpa_question_set_id, :order_id)
  end

  def submit_answers_params
    params.permit(answers: [ :tpa_question_id, :selected_option ])
  end

  def create_tpa_test
    @tpa_test = Tpa::CreateServices.new(
      current_user,
      tpa_test_params[:tpa_question_set_id],
      tpa_test_params[:order_id]
    ).call

    test_data = Tpa::TestSerializer.new(@tpa_test, include_questions: true).to_h

    json_response({ data: test_data }, :ok, false)
  end
end
