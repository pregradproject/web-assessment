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

## Kamal Deployment

This project uses Kamal for containerized deployment to production servers. Kamal automates Docker-based deployments with zero-downtime rolling updates.

### Configuration Overview

- **Main Config**: `config/deploy.yml` - Primary Kamal configuration
- **Secrets**: `.kamal/secrets` - Environment variables and secrets (safe for git)
- **Dockerfile**: Multi-stage production build optimized for Rails 8
- **Docker Entrypoint**: `bin/docker-entrypoint` - Database preparation and jemalloc setup
- **Hooks**: `.kamal/hooks/` - Deployment lifecycle hooks (samples provided)

### Environment Setup

**Required Secrets** (configured in `.kamal/secrets`):
- `KAMAL_REGISTRY_PASSWORD` - Docker registry authentication
- `RAILS_MASTER_KEY` - Rails encryption key (auto-loaded from `config/master.key`)

**Environment Variables**:
- `SOLID_QUEUE_IN_PUMA=true` - Runs background jobs in Puma process
- Database and concurrency settings configurable per deployment

### Current Configuration (Needs Customization)

- **Service**: `web_assessment`
- **Image**: `your-user/web_assessment` (update with actual registry)
- **Server**: `192.168.0.1` (update with production server IP)
- **Domain**: `app.example.com` (update with actual domain)
- **SSL**: Enabled via Let's Encrypt automatic certificates
- **Proxy**: Traefik for load balancing and SSL termination
- **Storage**: Persistent volume `web_assessment_storage:/rails/storage`

### Deployment Commands

**Essential Commands**:
- `bin/kamal setup` - Initial server setup and first deployment
- `bin/kamal deploy` - Deploy latest code with zero-downtime rolling update
- `bin/kamal rollback` - Rollback to previous deployment
- `bin/kamal lock` - Lock deployments to prevent conflicts
- `bin/kamal unlock` - Unlock deployments

**Management Aliases** (pre-configured shortcuts):
- `bin/kamal console` - Access Rails console in production
- `bin/kamal shell` - Access container bash shell
- `bin/kamal logs` - Stream application logs
- `bin/kamal dbc` - Access Rails database console

**Monitoring Commands**:
- `bin/kamal app logs` - View application logs
- `bin/kamal proxy logs` - View proxy logs
- `bin/kamal ps` - List running containers
- `bin/kamal images` - List deployed images

### Deployment Workflow

1. **Build Phase**: Kamal builds Docker image using multi-stage Dockerfile
   - Installs dependencies and gems
   - Precompiles assets and bootsnap cache
   - Creates production-optimized image

2. **Push Phase**: Built image pushed to configured Docker registry
   - Requires `KAMAL_REGISTRY_PASSWORD` authentication
   - Tagged with deployment timestamp

3. **Deploy Phase**: Rolling deployment to target servers
   - Pulls latest image to servers
   - Starts new containers alongside existing ones
   - Health checks ensure new version is working
   - Traffic switched to new containers
   - Old containers removed

4. **Proxy Setup**: Traefik automatically configured
   - SSL certificates via Let's Encrypt
   - Load balancing across containers
   - Health check endpoints

5. **Database Preparation**: Docker entrypoint handles DB setup
   - Runs `rails db:prepare` automatically
   - Includes migrations and schema setup

### Pre-Deployment Checklist

Before deploying, ensure:
- [ ] Update server IP in `config/deploy.yml` (`servers.web`)
- [ ] Update domain name (`proxy.host`)
- [ ] Update Docker image name (`image`)
- [ ] Update registry credentials (`registry.username`)
- [ ] Set `KAMAL_REGISTRY_PASSWORD` environment variable
- [ ] Verify `config/master.key` exists and is secure
- [ ] Test build locally: `docker build -t web_assessment .`

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

## API Response Best Practices

- For the API response, always use serializer
- Example: `json_response(Vark::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)` from `app/serializers/vark/active_question_set_serializer.rb`

## Service Naming Conventions

- Service names will be using plural, like Orders::CreateOrderServices.. so that it was not clased with Order model

## Service Development Notes

- When creating services, prefer simpler service method calls:
  - Instead of `@order = @test.build_order(...)`, use `@test.create(...)` 
  - Move validations like order existence and test completion checks to controllers or dedicated validator classes
  - Avoid adding multiple validation checks directly in service methods
  - Use separate validator classes in `app/validators/` for complex validation logic