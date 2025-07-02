# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0.2 API application for a web assessment platform focused on VARK (Visual, Auditory, Reading, Kinesthetic) learning style tests. The application provides:

- User authentication and management via JWT tokens
- VARK assessment functionality with question sets and result analysis
- Order and payment processing system
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
- **Order/Payment**: E-commerce functionality for paid assessments

### Services Architecture
- Services follow single responsibility pattern in `app/services/`
- **VarkServices**: Handle test creation and answer submission logic
- **OrderServices**: Manage order processing and payment workflows
- **ApplicationService**: Base service class pattern

### Validation & Security
- Custom validators in `app/validators/` for complex business logic
- JWT token authentication with expiration handling
- CSRF protection enabled for JSON requests
- Custom exception classes in `lib/ckv_exceptions/`

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

### API Design
- RESTful endpoints under `/api/v1/`
- JWT authentication required for protected endpoints
- Consistent JSON response structure
- Proper HTTP status codes and error messages

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