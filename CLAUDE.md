# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0.2 API application for a web assessment platform focused on VARK (Visual, Auditory, Reading, Kinesthetic) learning style tests. The application provides:

- User authentication and management via JWT tokens
- VARK assessment functionality with question sets and comprehensive result analysis
- Advanced multiple VARK result system with 15 learning style combinations
- Order and payment processing system
- Certificate generation with digital signatures
- ActiveAdmin interface for content management
- RESTful API endpoints under `/api/v1`

## Development Commands

### Essential Commands
- `rails server` - Start the development server
- `rails console` - Interactive Rails console
- `rails db:create` - Create databases
- `rails db:migrate` - Run database migrations
- `rails db:seed` - Seed the database with initial data
- `rails db:reset` - Drop, create, migrate, and seed database

### Code Quality
- `rubocop` - Run linting checks (configured with rubocop-rails-omakase)
- `rubocop -a` - Auto-fix linting issues
- `brakeman` - Security vulnerability scanning
- `rails test` - Run the test suite
- `rails test:models` - Run model tests specifically
- `rails test:controllers` - Run controller tests specifically

### Job Queue Management
- `rails solid_queue:start` - Start Solid Queue worker processes
- `rails solid_queue:stop` - Stop Solid Queue worker processes
- `rails solid_queue:restart` - Restart Solid Queue worker processes
- `rails jobs:work` - Start a single job worker process (for development)
- Queue monitoring available at `/jobs` via Mission Control Jobs interface

### Kamal Deployment (with Solid Queue)
- `kamal deploy` - Deploy both web and job services
- `kamal app start -r job` - Start only job servers
- `kamal app stop -r job` - Stop only job servers
- `kamal job-logs` - View logs from job servers
- `kamal job-shell` - Open shell in job container
- `kamal job-restart` - Restart job servers

### Admin User Management via Kamal
- `kamal admin-create` - Create admin user with default credentials
- `kamal admin-list` - List all admin users
- Environment variables for custom admin creation:
  - `ADMIN_EMAIL` - Custom admin email (default: admin@cakravia.web.id)
  - `ADMIN_PASSWORD` - Custom admin password (auto-generated if not provided)

### Local Admin Management
- `rails admin:create_user` - Create admin user locally
- `rails admin:list` - List admin users locally
- `ADMIN_EMAIL=custom@email.com ADMIN_PASSWORD=mypass rails admin:create_user`

### Asset Management
- `rails assets:precompile` - Precompile assets for production
- `rails assets:clean` - Clean old assets

## Architecture & Key Components

### API Structure
- **Base Controller**: `ApiController` handles JWT authentication, CSRF protection, and global error handling
- **Authentication**: JWT-based authentication with token validation in headers
- **Response Format**: Standardized JSON responses via `Response` concern
- **Error Handling**: Global exception handling via `ExceptionHandler` concern

### Core Models
- **User**: Main user model with authentication capabilities
- **VarkTest**: Assessment test instances with time limits and scoring
- **VarkQuestion/VarkQuestionSet**: Question management and categorization
- **VarkCategory**: Learning style categories (Visual, Auditory, Reading, Kinesthetic)
- **VarkResultDescription**: Comprehensive learning style descriptions for all 15 VARK combinations
- **VarkResultLevel**: Individual test result scores, percentages, and dominant learning style analysis
- **Order/Payment**: E-commerce functionality for paid assessments
- **Signature**: Digital certificate signing functionality

### Services Architecture
- Services follow single responsibility pattern in `app/services/`
- **VarkServices**: Handle test creation, answer submission, and result analysis logic
- **Vark::ResultDescriptionMatcher**: Sophisticated pattern matching for VARK result descriptions with fallback strategies
- **OrderServices**: Manage order processing and payment workflows
- **ApplicationService**: Base service class pattern

### Validation & Security
- Custom validators in `app/validators/` for complex business logic
- JWT token authentication with expiration handling
- CSRF protection enabled for JSON requests
- Custom exception classes in `lib/ckv_exceptions/` (including NotFoundError for 404 responses)

### Admin Interface
- ActiveAdmin for content management at `/admin`
- Separate admin user model with Devise authentication
- Mission Control Jobs for background job monitoring

### Database
- SQLite3 for development/test
- PostgreSQL for production (configured in Gemfile)
- Active Storage for file uploads
- Solid Cache, Queue, and Cable for Rails 8 features

## Code Style & Standards

### Ruby/Rails Conventions
- Follow rubocop-rails-omakase style guide
- Maximum line length: 100 characters
- Maximum method length: 10 lines
- Use single quotes for strings
- Documentation comments disabled by style guide

### File Organization
- Controllers use concerns for shared functionality
- Services in dedicated namespace directories
- Serializers use jsonapi-serializer gem
- Custom validators in dedicated validator classes
- **Validation Pattern**: Instead of multiple unprocessable entity validations in controllers, create separate validator classes in `app/validators/` (similar to `app/validators/vark/submit_answer_validator.rb`) and use them with `raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?`

### API Design
- RESTful endpoints under `/api/v1/`
- JWT authentication required for protected endpoints
- Consistent JSON response structure
- Proper HTTP status codes and error messages
- **Always use serializers for API responses**: `json_response(Serializer.new(data).to_h, :ok, false)` instead of raw hash responses

## Testing

- Rails testing framework (not RSpec)
- Test files in `test/` directory following Rails conventions
- System tests use Capybara and Selenium WebDriver
- Fixtures for test data in `test/fixtures/`

## Configuration Notes

- Environment-specific configs in `config/environments/`
- Routes split into separate files in `config/routes/`
- Autoloading configured for `lib/` directory
- Mission Control Jobs integrated for job monitoring
- Exception handling configured for API responses

## Code Generation Reminders

- Always remember that for service, controller, validation, and serializer.. you need to use existing format.. example is vark_test
- **Namespace conflicts**: Avoid using model class names as module names (e.g., don't use `Order` as a module since it's already a model class). Use descriptive module names like `OrderServices`, `VarkServices`, etc.
- **Service naming**: Use plural module names like `Orders::CreateOrderServices` to avoid conflicts with singular model names
- **Service validation**: Don't add validation logic in services (like `raise CkvExceptions::UnprocessableEntityError`). Put validations in controllers or dedicated validator classes
- **Service database operations**: Use `create` methods instead of `build` + `save` patterns in services

## Development Best Practices

- Always run rubocop -A after you change something, and if there are rubocop errors.. try to fix it first

## Code Generation Guidelines

- 1 file will only have 1 class, create a new class if necessary but add it to appropriate folder
- For service classes about vark order creation, add the service to vark folder and name it create order services
- No need to add rescue, as there is already a global rescue in `app/controllers/concerns/exception_handler.rb`
- For exceptions, use `lib/ckv_exceptions` to return specific status codes (e.g., 422 or 403)
- Example validation pattern: `raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?`
- Use `CkvExceptions::NotFoundError` for 404 responses when resources are not found

## Background Jobs Usage

### Creating Jobs
- Jobs should inherit from `ApplicationJob` and be placed in `app/jobs/`
- Use `queue_as :queue_name` to specify queue (defaults to `:default`)
- Example: `SampleJob.perform_later("Hello World")` to enqueue a job
- Example: `SampleJob.perform_now("Hello World")` to execute immediately

### Queue Configuration
- Solid Queue is configured for development and production environments
- Test environment uses `:test` adapter for faster testing
- Configuration in `config/queue.yml` controls worker processes and polling
- Production uses separate database connection for queue tables

## CORS Configuration

### Development
- CORS is configured to allow all origins (`*`) for development
- All HTTP methods are supported for API endpoints under `/api/*`
- Authorization headers are exposed for JWT authentication

### Production
- CORS origins controlled by `CORS_ORIGINS` environment variable
- Default production origin: `https://cakravia.web.id`
- Multiple origins can be specified as comma-separated values
- Example: `CORS_ORIGINS=https://app.example.com,https://admin.example.com`

## Email Configuration

### Development (MailHog)
- Uses MailHog for email testing on port 1025
- No authentication required for localhost connections
- Emails viewable at http://localhost:8025

### Production (Local Mail Server)
- Uses localhost mail server running on same VPS
- No SMTP authentication required (trusted local connection)
- Configuration: `address: 'localhost', port: 25, domain: 'cakravia.com'`
- Mail server accepts connections from localhost without username/password
- Secure because only local machine can connect

### Password Reset Features
- Secure token-based password reset with 1-hour expiration
- Professional email templates with Cakravia branding
- Support for both email/password and Google OAuth users
- Rate limiting and comprehensive validation
- API endpoints: `/password_reset`, `/password_reset_confirm`, `/password_change`

## API Response Best Practices

- For the API response, always use serializer
- Example: `json_response(Vark::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)` from `app/serializers/vark/active_question_set_serializer.rb`
- Test results include comprehensive analysis via `Vark::TestResultsSerializer` with detailed learning style descriptions, study recommendations, and career suggestions

## Service Naming Conventions

- Service names will be using plural, like Orders::CreateOrderServices.. so that it was not clased with Order model

## Service Development Notes

- When creating services, prefer simpler service method calls:
  - Instead of `@order = @test.build_order(...)`, use `@test.create(...)` 
  - Move validations like order existence and test completion checks to controllers or dedicated validator classes
  - Avoid adding multiple validation checks directly in service methods
  - Use separate validator classes in `app/validators/` for complex validation logic

## VARK Result System

### Multiple Result Combinations
- Supports 15 different VARK learning style combinations:
  - Single-modal: V, A, R, K (4 combinations)
  - Dual-modal: VA, VR, VK, AR, AK, RK (6 combinations)
  - Triple-modal: VAR, VAK, VRK, ARK (4 combinations)
  - Balanced multimodal: VARK (1 combination)

### Result Analysis Features
- **VarkResultDescription**: Comprehensive descriptions for each combination including:
  - Detailed learning style analysis
  - Study recommendations and strategies
  - Career suggestions and paths
  - Strengths and challenges identification
- **VarkResultLevel**: Individual score analysis with percentages and dominant style identification
- **ResultDescriptionMatcher**: Intelligent pattern matching with fallback strategies for partial matches

### Seed Data
- Complete seed data available in `db/seeds/vark_result_descriptions.rb`
- Covers all 15 possible VARK combinations
- Each description includes title, characteristics, study tips, career suggestions, strengths, and challenges
