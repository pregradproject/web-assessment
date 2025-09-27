# Tasks: TPA (Tes Potensi Akademik) Test Module

**Input**: Design documents from `/home/arymprayoga/web-assessment/specs/003-please-learn-the/`
**Prerequisites**: plan.md, research.md, data-model.md, contracts/tpa_api.yml, quickstart.md

## Execution Flow (main)
```
1. Load plan.md from feature directory
   ✓ Found: Rails 8.0.2, ActiveAdmin, JWT authentication, jsonapi-serializer
2. Load design documents:
   ✓ data-model.md: 6 entities (TpaCategory, TpaQuestionSet, TpaQuestion, TpaTest, TpaAnswer, TpaResultLevel)
   ✓ contracts/tpa_api.yml: 5 API endpoints
   ✓ research.md: Rails patterns analysis
   ✓ quickstart.md: Integration test scenarios
3. Generate tasks by category: 35 tasks total
4. Apply task rules: TDD approach, [P] for parallel execution
5. Number tasks sequentially (T001-T035)
6. Validate completeness: All entities, contracts, and scenarios covered
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Phase 3.1: Setup & Dependencies
- [x] T001 Verify Rails environment and dependencies from plan.md
- [x] T002 Add TPA routes to config/routes.rb under api/v1 namespace
- [x] T003 [P] Configure TPA certificate category in Order model enum

## Phase 3.2: Database Migrations ⚠️ MUST COMPLETE BEFORE MODELS
- [x] T004 [P] Create TPA categories migration in db/migrate/create_tpa_categories.rb
- [x] T005 [P] Create TPA question sets migration in db/migrate/create_tpa_question_sets.rb
- [x] T006 [P] Create TPA questions migration in db/migrate/create_tpa_questions.rb
- [x] T007 [P] Create TPA tests migration in db/migrate/create_tpa_tests.rb
- [x] T008 [P] Create TPA answers migration in db/migrate/create_tpa_answers.rb
- [x] T009 [P] Create TPA result levels migration in db/migrate/create_tpa_result_levels.rb
- [x] T010 Run database migrations and verify schema

## Phase 3.3: Contract Tests First (TDD) ⚠️ MUST COMPLETE BEFORE IMPLEMENTATION
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [x] T011 [P] Contract test GET /api/v1/tpa_tests in test/controllers/api/v1/tpa_tests_controller_test.rb
- [x] T012 [P] Contract test POST /api/v1/tpa_tests in same test file as T011
- [x] T013 [P] Contract test GET /api/v1/tpa_tests/active_question_set in same test file as T011
- [x] T014 [P] Contract test GET /api/v1/tpa_tests/:id in same test file as T011
- [x] T015 [P] Contract test POST /api/v1/tpa_tests/:id/submit_answers in same test file as T011
- [x] T016 [P] Contract test GET /api/v1/tpa_tests/:id/results in same test file as T011

## Phase 3.4: Model Implementation (ONLY after migrations and tests are failing)
- [x] T017 [P] TpaCategory model in app/models/tpa_category.rb
- [x] T018 [P] TpaQuestionSet model in app/models/tpa_question_set.rb
- [x] T019 [P] TpaQuestion model with ActiveStorage in app/models/tpa_question.rb
- [x] T020 [P] TpaTest model in app/models/tpa_test.rb
- [x] T021 [P] TpaAnswer model in app/models/tpa_answer.rb
- [x] T022 [P] TpaResultLevel model in app/models/tpa_result_level.rb

## Phase 3.5: Service Layer Implementation
- [x] T023 [P] TPA create test service in app/services/tpa/create_services.rb
- [x] T024 [P] TPA submit answers service in app/services/tpa/submit_answers_services.rb
- [x] T025 [P] TPA result calculation service in app/services/tpa/result_calculation_services.rb

## Phase 3.6: Validation Classes
- [x] T026 [P] TPA submit answer validator in app/validators/tpa/submit_answer_validator.rb
- [x] T027 [P] TPA test results validator in app/validators/tpa/test_results_validator.rb

## Phase 3.7: Serializers
- [x] T028 [P] TPA test serializer in app/serializers/tpa/test_serializer.rb
- [x] T029 [P] TPA active question set serializer in app/serializers/tpa/active_question_set_serializer.rb
- [x] T030 [P] TPA test results serializer in app/serializers/tpa/test_results_serializer.rb

## Phase 3.8: Controller Implementation
- [x] T031 TPA tests controller in app/controllers/api/v1/tpa_tests_controller.rb

## Phase 3.9: ActiveAdmin Configuration
- [x] T032 [P] TPA categories admin in app/admin/tpa_categories.rb
- [x] T033 [P] TPA question sets admin in app/admin/tpa_question_sets.rb
- [x] T034 [P] TPA questions admin in app/admin/tpa_questions.rb
- [x] T035 [P] TPA tests admin in app/admin/tpa_tests.rb

## Phase 3.10: Integration & Validation
- [x] T036 Seed TPA categories data for 4 subject areas
- [x] T037 Run quickstart.md scenarios to validate implementation
- [x] T038 Update Order model for TPA certificate integration

## Dependencies
- Migrations (T004-T010) before models (T017-T022)
- Contract tests (T011-T016) before controller implementation (T031)
- Models (T017-T022) before services (T023-T025)
- Services (T023-T025) before controller (T031)
- Validators (T026-T027) before controller (T031)
- Serializers (T028-T030) before controller (T031)
- Controller (T031) before integration tests (T036-T038)

## Parallel Execution Examples

### Database Migrations (after T003)
```bash
# Launch T004-T009 together:
rails generate migration CreateTpaCategories name:string code:string description:text
rails generate migration CreateTpaQuestionSets name:string version:string active:boolean time_limit:integer
rails generate migration CreateTpaQuestions tpa_category:references tpa_question_set:references question_text:text option_a:text option_b:text option_c:text option_d:text option_e:text correct_answer:string explanation:text difficulty_level:integer
rails generate migration CreateTpaTests user:references tpa_question_set:references status:integer started_at:datetime completed_at:datetime
rails generate migration CreateTpaAnswers tpa_test:references tpa_question:references selected_option:string is_correct:boolean answered_at:datetime
rails generate migration CreateTpaResultLevels tpa_test:references total_score:integer total_questions:integer average_score:decimal level_label:string level_message:text verbal_score:integer quantitative_score:integer analytic_score:integer spatial_score:integer
```

### Contract Tests (after T010)
```bash
# Launch T011-T016 together:
Task: "Contract test GET /api/v1/tpa_tests in test/controllers/api/v1/tpa_tests_controller_test.rb"
Task: "Contract test POST /api/v1/tpa_tests in same test file"
Task: "Contract test GET /api/v1/tpa_tests/active_question_set in same test file"
Task: "Contract test GET /api/v1/tpa_tests/:id in same test file"
Task: "Contract test POST /api/v1/tpa_tests/:id/submit_answers in same test file"
Task: "Contract test GET /api/v1/tpa_tests/:id/results in same test file"
```

### Model Implementation (after T016)
```bash
# Launch T017-T022 together:
Task: "TpaCategory model in app/models/tpa_category.rb"
Task: "TpaQuestionSet model in app/models/tpa_question_set.rb"
Task: "TpaQuestion model with ActiveStorage in app/models/tpa_question.rb"
Task: "TpaTest model in app/models/tpa_test.rb"
Task: "TpaAnswer model in app/models/tpa_answer.rb"
Task: "TpaResultLevel model in app/models/tpa_result_level.rb"
```

### Service Layer (after T022)
```bash
# Launch T023-T025 together:
Task: "TPA create test service in app/services/tpa/create_services.rb"
Task: "TPA submit answers service in app/services/tpa/submit_answers_services.rb"
Task: "TPA result calculation service in app/services/tpa/result_calculation_services.rb"
```

### Validators (after T025)
```bash
# Launch T026-T027 together:
Task: "TPA submit answer validator in app/validators/tpa/submit_answer_validator.rb"
Task: "TPA test results validator in app/validators/tpa/test_results_validator.rb"
```

### Serializers (after T027)
```bash
# Launch T028-T030 together:
Task: "TPA test serializer in app/serializers/tpa/test_serializer.rb"
Task: "TPA active question set serializer in app/serializers/tpa/active_question_set_serializer.rb"
Task: "TPA test results serializer in app/serializers/tpa/test_results_serializer.rb"
```

### ActiveAdmin (after T031)
```bash
# Launch T032-T035 together:
Task: "TPA categories admin in app/admin/tpa_categories.rb"
Task: "TPA question sets admin in app/admin/tpa_question_sets.rb"
Task: "TPA questions admin in app/admin/tpa_questions.rb"
Task: "TPA tests admin in app/admin/tpa_tests.rb"
```

## Notes
- [P] tasks = different files, no dependencies between them
- Verify contract tests fail before implementing controllers
- Follow existing Rails patterns from comprehensive_assessment and behavioral_learning modules
- Use existing exception classes in lib/ckv_exceptions/
- Follow jsonapi-serializer patterns for API responses
- Commit after each task completion
- Test file paths follow Rails conventions: test/models/, test/controllers/, etc.

## Specific Implementation Notes

### Model Requirements
- TpaCategory: 4 fixed categories (Verbal="V", Quantitative="Q", Analytic="A", Spatial="S")
- TpaQuestionSet: Only one can be active at a time, includes time_limit configuration
- TpaQuestion: Support ActiveStorage image attachment, 5 multiple choice options (A-E)
- TpaTest: Polymorphic association with Order, status enum (in_progress, completed, expired)
- TpaAnswer: Unique constraint on [tpa_test_id, tpa_question_id]
- TpaResultLevel: Category-specific scores and comprehensive analytics

### API Requirements
- JWT authentication required for all endpoints
- Follow existing ApiController patterns
- Use jsonapi-serializer for response formatting
- Proper error handling with CkvExceptions classes
- Time limit enforcement for test submissions

### ActiveAdmin Requirements
- Follow existing admin interface patterns
- Support image upload for questions
- Question set management with active toggle
- Test result viewing capabilities
- Category and difficulty filtering

## Validation Checklist
*GATE: Checked before task execution begins*

- [x] All 5 API contracts have corresponding tests (T011-T016)
- [x] All 6 entities have model tasks (T017-T022)
- [x] All contract tests come before implementation (T011-T016 → T031)
- [x] Parallel tasks truly independent (marked with [P])
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Dependencies properly ordered (migrations → models → services → controller)
- [x] TDD approach: tests before implementation throughout