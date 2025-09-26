# TPA Test Module Quickstart Guide

## Overview
This guide validates the TPA (Tes Potensi Akademik) test module implementation through step-by-step user scenarios.

## Prerequisites
- Rails application running locally
- User account created and authenticated
- Database migrated with TPA tables
- ActiveAdmin configured with TPA models
- Test data seeded (questions, categories, question sets)

## Test Scenarios

### Scenario 1: Administrator Setup
**Goal**: Verify admin can configure TPA test content

```bash
# 1. Access ActiveAdmin interface
open http://localhost:3000/admin

# 2. Log in as admin user
# Use admin credentials from rails admin:create_user

# 3. Navigate to TPA Categories
# Verify 4 categories exist: Verbal, Quantitative, Analytic, Spatial

# 4. Create a TPA Question Set
# - Name: "TPA Practice Set v1.0"
# - Version: "1.0"
# - Active: true
# - Time Limit: 3600 seconds

# 5. Add TPA Questions
# Create at least 20 questions distributed across categories:
# - 5 Verbal questions
# - 5 Quantitative questions
# - 5 Analytic questions
# - 5 Spatial questions

# 6. Verify each question has:
# - Question text
# - 5 options (A, B, C, D, E)
# - Correct answer marked
# - Category assigned
# - Optional image attachment
```

**Expected Result**: Admin can successfully create and manage TPA content

### Scenario 2: User Test Purchase Flow
**Goal**: Verify user can purchase TPA test access

```bash
# API calls using curl or HTTP client

# 1. Authenticate user
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

# Store JWT token from response
export JWT_TOKEN="<token_from_response>"

# 2. Get active question set
curl -X GET http://localhost:3000/api/v1/tpa_tests/active_question_set \
  -H "Authorization: Bearer $JWT_TOKEN"

# 3. Create order for TPA test
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"category": "tpa_certificate", "amount": 50000}'

# 4. Process payment (mock or actual Midtrans)
# Payment processing depends on implementation

# 5. Verify order status is "paid"
curl -X GET http://localhost:3000/api/v1/orders/<order_id> \
  -H "Authorization: Bearer $JWT_TOKEN"
```

**Expected Result**: User can successfully purchase test access

### Scenario 3: Taking the TPA Test
**Goal**: Verify complete test-taking experience

```bash
# 1. Create new test instance
curl -X POST http://localhost:3000/api/v1/tpa_tests \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tpa_question_set_id": 1}'

# Store test ID from response
export TEST_ID="<test_id_from_response>"

# 2. Get test details with questions
curl -X GET http://localhost:3000/api/v1/tpa_tests/$TEST_ID \
  -H "Authorization: Bearer $JWT_TOKEN"

# 3. Submit answers for all questions
curl -X POST http://localhost:3000/api/v1/tpa_tests/$TEST_ID/submit_answers \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {"tpa_question_id": 1, "selected_option": "A"},
      {"tpa_question_id": 2, "selected_option": "B"},
      {"tpa_question_id": 3, "selected_option": "C"}
    ]
  }'

# 4. Get test results
curl -X GET http://localhost:3000/api/v1/tpa_tests/$TEST_ID/results \
  -H "Authorization: Bearer $JWT_TOKEN"
```

**Expected Result**: User can complete test and receive detailed results

### Scenario 4: Results and Analytics
**Goal**: Verify comprehensive result analysis

```json
// Expected result structure from GET /api/v1/tpa_tests/:id/results
{
  "data": {
    "id": 1,
    "total_score": 15,
    "total_questions": 20,
    "average_score": 75.0,
    "level_label": "Good",
    "level_message": "You have demonstrated good academic potential...",
    "category_scores": {
      "verbal": 4,
      "quantitative": 3,
      "analytic": 4,
      "spatial": 4
    },
    "category_breakdown": {
      "verbal": {"score": 4, "total": 5, "percentage": 80.0},
      "quantitative": {"score": 3, "total": 5, "percentage": 60.0},
      "analytic": {"score": 4, "total": 5, "percentage": 80.0},
      "spatial": {"score": 4, "total": 5, "percentage": 80.0}
    },
    "strongest_categories": ["Verbal", "Analytic", "Spatial"],
    "weakest_categories": ["Quantitative"],
    "detailed_analysis": {
      "strengths": ["Strong verbal reasoning", "Excellent spatial intelligence"],
      "areas_for_improvement": ["Mathematical problem solving"],
      "overall_assessment": "Your overall academic potential score is 75.0%, indicating good performance.",
      "recommendations": ["Focus on quantitative skills through practice problems"]
    },
    "test_info": {
      "id": 1,
      "completed_at": "2025-09-26T10:30:00Z",
      "question_set": {
        "id": 1,
        "name": "TPA Practice Set v1.0",
        "version": "1.0"
      }
    }
  }
}
```

**Expected Result**: Results include comprehensive analytics and recommendations

### Scenario 5: Certificate Generation
**Goal**: Verify certificate PDF generation

```bash
# 1. Check certificate status
curl -X GET http://localhost:3000/api/v1/orders/<order_id> \
  -H "Authorization: Bearer $JWT_TOKEN"

# 2. Download certificate (if generated)
curl -X GET http://localhost:3000/api/v1/orders/<order_id>/certificate \
  -H "Authorization: Bearer $JWT_TOKEN" \
  --output tpa_certificate.pdf

# 3. Verify PDF contains:
# - User name
# - Test completion date
# - Overall score and percentage
# - Category breakdown
# - Official signature/seal
```

**Expected Result**: PDF certificate generated with comprehensive test results

### Scenario 6: Edge Cases and Error Handling
**Goal**: Verify robust error handling

```bash
# 1. Attempt to access test without payment
curl -X POST http://localhost:3000/api/v1/tpa_tests \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tpa_question_set_id": 1}'
# Expected: 403 Forbidden

# 2. Submit answers to already completed test
curl -X POST http://localhost:3000/api/v1/tpa_tests/$COMPLETED_TEST_ID/submit_answers \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"answers": []}'
# Expected: 403 Forbidden

# 3. Access results of incomplete test
curl -X GET http://localhost:3000/api/v1/tpa_tests/$INCOMPLETE_TEST_ID/results \
  -H "Authorization: Bearer $JWT_TOKEN"
# Expected: 422 Unprocessable Entity

# 4. Submit invalid answer options
curl -X POST http://localhost:3000/api/v1/tpa_tests/$TEST_ID/submit_answers \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"answers": [{"tpa_question_id": 1, "selected_option": "Z"}]}'
# Expected: 422 Unprocessable Entity

# 5. Test time expiration
# Wait for test time limit to expire, then submit answers
# Expected: 403 Forbidden with "Test time expired" message
```

**Expected Result**: All edge cases handled gracefully with appropriate error responses

## Validation Checklist

### Functional Requirements
- [ ] Users can purchase TPA test packages
- [ ] Multiple-choice questions with 5 options (A-E) work correctly
- [ ] Image attachments display properly in questions
- [ ] Scoring calculates correctly (1 point per correct answer)
- [ ] Results include category breakdowns for all 4 subjects
- [ ] PDF certificates generate successfully
- [ ] Time limits enforce correctly
- [ ] ActiveAdmin interface manages all TPA content

### Technical Requirements
- [ ] API responses match OpenAPI contract specifications
- [ ] JWT authentication works for all endpoints
- [ ] Database queries perform efficiently with indexes
- [ ] Image uploads validate file types and sizes
- [ ] Background jobs process certificate generation
- [ ] Error responses include appropriate status codes and messages

### Integration Requirements
- [ ] Midtrans payment processing integration works
- [ ] Order model polymorphic association functions correctly
- [ ] Certificate system generates TPA-specific PDFs
- [ ] Admin interface follows existing patterns
- [ ] Test module follows same architecture as other modules

### Performance Requirements
- [ ] API response times under 500ms
- [ ] Image uploads handle files up to 5MB
- [ ] Concurrent test sessions supported
- [ ] Database queries optimized with proper indexes

## Troubleshooting

### Common Issues
1. **JWT Token Expired**: Re-authenticate to get new token
2. **Image Upload Fails**: Check file size and format restrictions
3. **Test Creation Forbidden**: Verify order payment status
4. **Results Not Available**: Ensure test is completed status
5. **Admin Access Denied**: Verify admin user credentials

### Database Queries for Debugging
```sql
-- Check active question set
SELECT * FROM tpa_question_sets WHERE active = true;

-- Verify question distribution
SELECT tc.name, COUNT(*) FROM tpa_questions tq
JOIN tpa_categories tc ON tq.tpa_category_id = tc.id
GROUP BY tc.name;

-- Check test progress
SELECT id, status, started_at, completed_at FROM tpa_tests WHERE user_id = ?;

-- Verify payment status
SELECT id, status, category FROM orders WHERE testable_type = 'TpaTest';
```

This quickstart guide provides comprehensive validation of the TPA test module functionality and serves as both documentation and acceptance testing criteria.