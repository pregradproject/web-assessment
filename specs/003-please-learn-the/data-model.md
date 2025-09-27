# Data Model: TPA Test Module

## Entity Relationships

```
TpaCategory (1) ←→ (N) TpaQuestion
TpaQuestionSet (1) ←→ (N) TpaQuestion
TpaQuestionSet (1) ←→ (N) TpaTest
TpaQuestion (1) ←→ (N) TpaAnswer
TpaTest (1) ←→ (N) TpaAnswer
TpaTest (1) ←→ (1) TpaResultLevel
TpaTest (1) ←→ (1) Order (polymorphic)
User (1) ←→ (N) TpaTest
```

## Core Entities

### TpaCategory
**Purpose**: Subject classification for questions (Verbal, Quantitative, Analytic, Spatial)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| name | String | NOT NULL, unique | Category name (e.g., "Verbal Reasoning") |
| code | String | NOT NULL, unique, 1-2 chars | Short code (e.g., "V", "Q", "A", "S") |
| description | Text | Optional | Detailed category description |
| created_at | DateTime | NOT NULL | Record creation timestamp |
| updated_at | DateTime | NOT NULL | Record modification timestamp |

**Validations**:
- Name presence and uniqueness
- Code presence, uniqueness, and format (1-2 uppercase letters)
- Description length (max 500 characters)

### TpaQuestionSet
**Purpose**: Active question collections that determine test content

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| name | String | NOT NULL | Question set name |
| version | String | NOT NULL | Version identifier |
| active | Boolean | NOT NULL, default: false | Whether this set is currently active |
| time_limit | Integer | NOT NULL, default: 3600 | Time limit in seconds |
| created_at | DateTime | NOT NULL | Record creation timestamp |
| updated_at | DateTime | NOT NULL | Record modification timestamp |

**Validations**:
- Name presence and length (max 100 characters)
- Version presence and format
- Only one active question set allowed at a time
- Time limit must be positive integer

**Scopes**:
- `active`: Returns currently active question set
- `current_active`: Returns most recent active question set

### TpaQuestion
**Purpose**: Individual test questions with multiple choice options

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| tpa_category_id | Integer | Foreign Key, NOT NULL | Associated category |
| tpa_question_set_id | Integer | Foreign Key, NOT NULL | Associated question set |
| question_text | Text | NOT NULL | Question content |
| option_a | Text | NOT NULL | Choice A |
| option_b | Text | NOT NULL | Choice B |
| option_c | Text | NOT NULL | Choice C |
| option_d | Text | NOT NULL | Choice D |
| option_e | Text | NOT NULL | Choice E |
| correct_answer | String | NOT NULL, enum | Correct option (A/B/C/D/E) |
| explanation | Text | Optional | Answer explanation |
| difficulty_level | Integer | Default: 1 | Question difficulty (1-5) |
| created_at | DateTime | NOT NULL | Record creation timestamp |
| updated_at | DateTime | NOT NULL | Record modification timestamp |

**Associations**:
- `has_one_attached :image` (optional diagram/visual)
- `belongs_to :tpa_category`
- `belongs_to :tpa_question_set`
- `has_many :tpa_answers`

**Validations**:
- Question text presence and length (max 1000 characters)
- All options presence and length (max 200 characters each)
- Correct answer enum validation (A, B, C, D, E)
- Image file type validation (if attached)
- Difficulty level range (1-5)

### TpaTest
**Purpose**: Test instances purchased and taken by users

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| user_id | Integer | Foreign Key, NOT NULL | Test taker |
| tpa_question_set_id | Integer | Foreign Key, NOT NULL | Question set used |
| status | Integer | NOT NULL, enum, default: 0 | Test status |
| started_at | DateTime | Optional | When test was started |
| completed_at | DateTime | Optional | When test was completed |
| created_at | DateTime | NOT NULL | Record creation timestamp |
| updated_at | DateTime | NOT NULL | Record modification timestamp |

**Associations**:
- `belongs_to :user`
- `belongs_to :tpa_question_set`
- `has_many :tpa_answers, dependent: :destroy`
- `has_one :tpa_result_level, dependent: :destroy`
- `has_one :order, as: :testable, dependent: :destroy`

**Enums**:
- Status: `{ in_progress: 0, completed: 1, expired: 2 }`

**Validations**:
- Started at presence if status is in_progress
- Completed at presence if status is completed
- User and question set associations

**Instance Methods**:
- `time_remaining`: Calculate remaining time based on question set time limit
- `expired?`: Check if test has exceeded time limit

### TpaAnswer
**Purpose**: User responses to individual questions

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| tpa_test_id | Integer | Foreign Key, NOT NULL | Associated test |
| tpa_question_id | Integer | Foreign Key, NOT NULL | Associated question |
| selected_option | String | NOT NULL, enum | User's choice (A/B/C/D/E) |
| is_correct | Boolean | NOT NULL | Whether answer is correct |
| answered_at | DateTime | NOT NULL | When answer was submitted |
| created_at | DateTime | NOT NULL | Record creation timestamp |
| updated_at | DateTime | NOT NULL | Record modification timestamp |

**Associations**:
- `belongs_to :tpa_test`
- `belongs_to :tpa_question`

**Validations**:
- Selected option enum validation (A, B, C, D, E)
- Unique constraint on [tpa_test_id, tpa_question_id]
- Answered at presence

### TpaResultLevel
**Purpose**: Comprehensive test results and analytics

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| tpa_test_id | Integer | Foreign Key, NOT NULL, unique | Associated test |
| total_score | Integer | NOT NULL, default: 0 | Total correct answers |
| total_questions | Integer | NOT NULL | Total questions in test |
| average_score | Decimal | NOT NULL, precision: 5,2 | Score percentage |
| level_label | String | NOT NULL | Performance level label |
| level_message | Text | NOT NULL | Detailed level description |
| verbal_score | Integer | Default: 0 | Verbal category score |
| quantitative_score | Integer | Default: 0 | Quantitative category score |
| analytic_score | Integer | Default: 0 | Analytic category score |
| spatial_score | Integer | Default: 0 | Spatial category score |
| created_at | DateTime | NOT NULL | Record creation timestamp |
| updated_at | DateTime | NOT NULL | Record modification timestamp |

**Associations**:
- `belongs_to :tpa_test`

**Validations**:
- Total score non-negative and not exceeding total questions
- Average score range (0.0 to 100.0)
- Level label and message presence
- Category scores non-negative

**Instance Methods**:
- `category_score(category_code)`: Get score for specific category
- `category_average(category_code)`: Get percentage for specific category
- `strongest_categories`: Return top performing categories
- `weakest_categories`: Return lowest performing categories
- `detailed_result_data`: Comprehensive analytics hash

## State Transitions

### TpaTest Status Flow
```
created → in_progress (when started_at set)
in_progress → completed (when all answers submitted)
in_progress → expired (when time limit exceeded)
```

### Business Rules
1. **Question Set Activation**: Only one TpaQuestionSet can be active at a time
2. **Test Time Limits**: Tests expire based on question set time_limit
3. **Answer Uniqueness**: One answer per question per test
4. **Result Calculation**: Results generated only after test completion
5. **Payment Integration**: Tests require successful payment before access
6. **Category Distribution**: Questions should be distributed across all 4 categories

## Database Indexes

```sql
-- Performance optimization indexes
CREATE INDEX idx_tpa_tests_user_status ON tpa_tests(user_id, status);
CREATE INDEX idx_tpa_questions_set_category ON tpa_questions(tpa_question_set_id, tpa_category_id);
CREATE INDEX idx_tpa_answers_test_question ON tpa_answers(tpa_test_id, tpa_question_id);
CREATE INDEX idx_tpa_question_sets_active ON tpa_question_sets(active) WHERE active = true;
```