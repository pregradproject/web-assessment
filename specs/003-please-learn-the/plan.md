
# Implementation Plan: TPA (Tes Potensi Akademik) Test Module

**Branch**: `003-please-learn-the` | **Date**: 2025-09-26 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/home/arymprayoga/web-assessment/specs/003-please-learn-the/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Implement a new TPA (Tes Potensi Akademik) test module following the existing Rails application architecture. The module includes multiple-choice questions with image support, configurable test parameters, payment integration, result analytics, and certificate generation. The technical approach replicates patterns from existing test modules (comprehensive assessment, behavioral learning) with full ActiveAdmin integration.

## Technical Context
**Language/Version**: Ruby 3.1.2, Rails 8.0.2
**Primary Dependencies**: ActiveAdmin, Solid Queue, ActiveStorage, JWT authentication, jsonapi-serializer
**Storage**: SQLite3 (development), PostgreSQL (production), ActiveStorage for image attachments
**Testing**: Rails test framework, Capybara for system tests
**Target Platform**: Linux server, deployed via Kamal
**Project Type**: web - Rails API backend with existing admin interface
**Performance Goals**: Match existing test modules performance (~500ms API response times)
**Constraints**: Follow existing Rails patterns, integrate with Midtrans payment, support image uploads <5MB
**Scale/Scope**: Support thousands of concurrent test sessions, admin-configurable question sets, 4 subject categories

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: PASS - Constitution file contains template placeholders only
- No specific constitutional requirements defined
- Following existing Rails application patterns and conventions
- Maintaining consistency with current test module architecture
- No violations identified

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
app/
├── models/
│   ├── tpa_test.rb
│   ├── tpa_question.rb
│   ├── tpa_question_set.rb
│   ├── tpa_category.rb
│   ├── tpa_answer.rb
│   └── tpa_result_level.rb
├── controllers/api/v1/
│   └── tpa_tests_controller.rb
├── services/tpa/
│   ├── create_services.rb
│   ├── submit_answers_services.rb
│   └── result_calculation_services.rb
├── serializers/tpa/
│   ├── test_serializer.rb
│   ├── active_question_set_serializer.rb
│   └── test_results_serializer.rb
├── validators/tpa/
│   ├── submit_answer_validator.rb
│   └── test_results_validator.rb
└── admin/
    ├── tpa_tests.rb
    ├── tpa_questions.rb
    ├── tpa_question_sets.rb
    └── tpa_categories.rb

db/migrate/
├── create_tpa_tests.rb
├── create_tpa_questions.rb
├── create_tpa_question_sets.rb
├── create_tpa_categories.rb
├── create_tpa_answers.rb
└── create_tpa_result_levels.rb

test/
├── models/
├── controllers/
├── services/
├── serializers/
└── system/
```

**Structure Decision**: Rails MVC web application structure following existing test module patterns (comprehensive_assessment, behavioral_learning). All TPA components follow the established naming conventions and directory organization.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Follow TDD approach: contract tests → model tests → service tests → integration tests → implementation
- Mirror existing test module patterns (comprehensive_assessment, behavioral_learning)

**Specific Task Categories**:
1. **Database Tasks** [P]: Migrations for 6 core entities (TpaTest, TpaQuestion, TpaQuestionSet, TpaCategory, TpaAnswer, TpaResultLevel)
2. **Model Tasks** [P]: ActiveRecord models with validations, associations, and methods
3. **Contract Test Tasks**: API endpoint contract validation (5 endpoints)
4. **Service Tasks**: Business logic services (Create, SubmitAnswers, ResultCalculation)
5. **Controller Tasks**: API controllers with authentication and error handling
6. **Serializer Tasks** [P]: JSON API response serializers (3 serializers)
7. **Validator Tasks** [P]: Custom validation classes for complex business rules
8. **Admin Tasks** [P]: ActiveAdmin configurations for content management
9. **Integration Tasks**: End-to-end user scenarios from quickstart.md
10. **Seed Tasks**: Sample data for development and testing

**Ordering Strategy**:
- Phase 2a: Database migrations and models (foundation)
- Phase 2b: Contract tests (API specifications)
- Phase 2c: Services and controllers (business logic)
- Phase 2d: Serializers and validators (supporting components)
- Phase 2e: Admin interface and seeds (content management)
- Phase 2f: Integration tests and validation (end-to-end verification)

**TPA-Specific Considerations**:
- Follow exact naming conventions: tpa_* for all components
- Integrate with existing Order/Payment system via polymorphic association
- Support image attachments via ActiveStorage
- Implement 4-category scoring system (Verbal, Quantitative, Analytic, Spatial)
- Configure time limits and active question set patterns
- Generate detailed analytics similar to existing test modules

**Estimated Output**: 32-35 numbered, ordered tasks in tasks.md
- 6 migration tasks
- 6 model tasks
- 5 contract test tasks
- 3 service tasks
- 1 controller task
- 3 serializer tasks
- 2 validator tasks
- 4 admin tasks
- 3 integration test tasks
- 2 seed/data tasks

**Dependencies Identified**:
- TpaCategory must exist before TpaQuestion
- TpaQuestionSet must exist before TpaTest
- TpaTest must exist before TpaAnswer and TpaResultLevel
- Order integration requires existing payment system
- Certificate generation requires existing PDF system

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none required)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
