# Feature Specification: Coupon Code System for Checkout

**Feature Branch**: `002-i-want-to`
**Created**: 2025-09-17
**Status**: Draft
**Input**: User description: "i want to add coupon code feature on checkout, so FE can send coupon to BE on order and the BE will reduce the amount send to midtrans. the coupon will be managed via activeadmin. the coupon will have date expiry and count expiry. the count will be per user (1 user can only use the coupon x times)."

## Execution Flow (main)
```
1. Parse user description from Input
   � COMPLETED: Feature description parsed successfully
2. Extract key concepts from description
   � Identified: customers (users), checkout process, coupon codes, discount application, admin management, expiry rules
3. For each unclear aspect:
   � [NEEDS CLARIFICATION: Discount type - percentage or fixed amount?]
   � [NEEDS CLARIFICATION: Minimum order amount requirements?]
   � [NEEDS CLARIFICATION: Coupon validation rules beyond expiry?]
4. Fill User Scenarios & Testing section
   � User flow defined for coupon application during checkout
5. Generate Functional Requirements
   � Each requirement testable and specific
6. Identify Key Entities
   � Coupon, CouponUsage entities identified
7. Run Review Checklist
   � WARN "Spec has uncertainties" - clarifications needed
8. Return: PARTIAL SUCCESS (spec ready but has clarifications needed)
```

---

## � Quick Guidelines
-  Focus on WHAT users need and WHY
- L Avoid HOW to implement (no tech stack, APIs, code structure)
- =e Written for business stakeholders, not developers

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a customer completing a purchase, I want to apply a coupon code during checkout to receive a discount on my order total, so that I can save money on my purchase.

### Acceptance Scenarios
1. **Given** a valid coupon code exists and I'm at checkout, **When** I enter the coupon code and submit, **Then** the order total should be reduced by the coupon discount amount
2. **Given** I have an expired coupon code, **When** I try to apply it during checkout, **Then** I should see an error message stating the coupon has expired
3. **Given** I have already used a coupon the maximum allowed times, **When** I try to apply the same coupon again, **Then** I should see an error message stating I've reached the usage limit
4. **Given** I enter an invalid or non-existent coupon code, **When** I submit it, **Then** I should see an error message stating the coupon is invalid
5. **Given** I have successfully applied a coupon, **When** I proceed to payment, **Then** the reduced amount should be sent to the payment processor

### Edge Cases
- What happens when a coupon expires during the checkout process?
- How does the system handle concurrent usage of limited-use coupons?
- What happens if the coupon discount exceeds the order total?
- How are partial refunds handled when a coupon was applied?

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST allow customers to enter and apply coupon codes during the checkout process
- **FR-002**: System MUST validate coupon codes against expiry dates and reject expired coupons
- **FR-003**: System MUST track individual user usage of each coupon and enforce per-user usage limits
- **FR-004**: System MUST apply the coupon discount to the order total before sending payment amount to payment processor
- **FR-005**: System MUST provide clear error messages for invalid, expired, or usage-limit-exceeded coupons
- **FR-006**: Administrators MUST be able to create, edit, and manage coupon codes through ActiveAdmin interface
- **FR-007**: System MUST store coupon usage history for auditing and reporting purposes
- **FR-008**: System MUST prevent the same coupon from being applied multiple times to a single order
- **FR-009**: System MUST have both percentage and fixed coupon code type
- **FR-010**: System MUST no minimum amount of order needed
- **FR-011**: System MUST there are no limit on percentage

### Key Entities *(include if feature involves data)*
- **Coupon**: Represents a discount code with attributes including code, discount value, expiry date, per-user usage limit, and activation status
- **CouponUsage**: Tracks individual usage instances linking users to coupons with usage timestamps for enforcement of usage limits

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [ ] Review checklist passed (clarifications needed)

---