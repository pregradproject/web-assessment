
# Gemini Codebase Understanding

This document provides a high-level overview of the Ruby on Rails application in this repository.

## Project Overview

This is a Ruby on Rails application designed to provide a VARK learning style assessment. It includes user authentication (including Google login), a testing module, and a payment system for generating certificates. The application exposes a JSON API for these features. It also includes an ActiveAdmin interface for administration.

## Key Technologies

*   **Backend:** Ruby on Rails
*   **Database:** PostgreSQL
*   **Authentication:** Devise, JWT
*   **Authorization:** Pundit
*   **Admin Interface:** ActiveAdmin
*   **Background Jobs:** SolidQueue, MissionControl
*   **Deployment:** Kamal, Docker
*   **Testing:** RSpec, Capybara, Selenium

## Codebase Structure

The application follows a standard Rails directory structure.

*   `app/controllers/api/v1/`: Contains the API controllers for the application.
    *   `users_controller.rb`: Handles user registration, login, profile management, and password reset.
    *   `vark_tests_controller.rb`: Manages the VARK tests, including submitting answers and retrieving results.
    *   `orders_controller.rb`: Handles the payment process and certificate generation.
*   `app/models/`: Contains the ActiveRecord models.
    *   `user.rb`: Represents a user of the application.
    *   `vark_test.rb`: Represents a single VARK test taken by a user.
    *   `vark_question_set.rb`: Represents a set of questions for a VARK test.
    *   `order.rb`: Represents a user's order for a certificate.
*   `config/routes.rb`: The main routing file, which delegates to the files in `config/routes/`.
    *   `config/routes/api.rb`: Defines the API endpoints.
    *   `config/routes/admin.rb`: Sets up the ActiveAdmin routes.
*   `Gemfile`: Lists the project's dependencies.
*   `Dockerfile`: Defines the Docker image for the application.
*   `config/deploy.yml`: Configuration for Kamal deployment.

## Core Functionality

### User Management

*   Users can register, log in, and manage their profiles.
*   Authentication is handled by Devise and JWT.
*   Google login is supported.
*   Password reset functionality is available.

### VARK Assessment

*   Users can take a VARK test.
*   The test consists of a set of questions.
*   Users can submit their answers and view their results.

### Payments and Certificates

*   Users can pay for a certificate after completing a test.
*   The application integrates with a payment gateway (Midtrans, based on the webhook).
*   Users can download their certificates after successful payment.

### Administration

*   An ActiveAdmin interface is available for administrative tasks.

## Getting Started

1.  **Install dependencies:** `bundle install`
2.  **Set up the database:** `rails db:create db:migrate`
3.  **Run the application:** `rails server`

## Testing

*   Run the test suite with `rspec`.

## Deployment

*   The application is deployed using Kamal.
*   The deployment configuration is in `config/deploy.yml`.
