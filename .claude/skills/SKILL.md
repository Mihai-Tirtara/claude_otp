
# OTP Development Guidelines

**Description**: Comprehensive development guide for OTP (Grails/Groovy bioinformatics platform). Use when creating controllers, services, domains, workflows, GSP views, or working with GORM, Spring Security, Spock testing, Bootstrap UI, workflow orchestration, CodeNarc/ESLint validation. Covers MVC architecture (views, controllers, services, domains), service layer pattern, error handling, database migrations, testing strategies (Spock/Cypress), and Grails conventions.

## Purpose

Establish consistency and best practices across the OTP (One Touch Pipeline) bioinformatics platform using Grails 6.x/Groovy 3.x/Spring Boot 3.x patterns. OTP orchestrates complex bioinformatics workflows for NGS data processing.

## When to Use This Skill

Automatically activates when working on:

- Creating or modifying controllers, actions, HTTP endpoints
- Building services (business logic layer)
- Creating or modifying domain models (GORM entities)
- Implementing workflow orchestration (OtpWorkflow, LinearWorkflow)
- GSP views and Bootstrap UI components
- Database migrations (Liquibase changelogs)
- Spock unit/integration tests or Cypress E2E tests
- CodeNarc/ESLint static analysis
- Spring Security authorization (@PreAuthorize)
- LDAP/OAuth2/Keycloak authentication
- Bioinformatics pipeline configuration and execution

---

## Quick Start

### New Feature Checklist

- [ ] **Controller**: MVC pattern, delegate to service
- [ ] **Service**: @Transactional business logic
- [ ] **Domain**: GORM entity with constraints
- [ ] **GSP View**: Bootstrap-based UI (if needed)
- [ ] **Security**: @PreAuthorize annotations
- [ ] **Validation**: Domain constraints + custom validators
- [ ] **Tests**: Spock unit + integration tests + Cypress tests
- [ ] **Migration**: Liquibase changelog (if DB changes)
- [ ] **CodeNarc**: Pass static analysis

### New Workflow Checklist

- [ ] Implement OtpWorkflow trait
- [ ] Define WorkflowSteps
- [ ] Create Job implementations
- [ ] Artefact management (input/output tracking)
- [ ] Error handling and restart logic
- [ ] Integration tests
- [ ] Workflow tests (workflow-test/)
- [ ] Cluster job configuration

---

## Architecture Overview

### MVC Architecture (Grails)

```
HTTP Request
    ↓
GSP Views (presentation)
    ↓
Controllers (request handling)
    ↓
Services (business logic)
    ↓
GORM Domains (data model)
    ↓
Database (PostgreSQL)
```

**Key Principle:** Grails convention over configuration - each layer follows strict separation of concerns.

### Workflow Architecture

```
WorkflowRun
    ↓
WorkflowSteps
    ↓
Jobs (Abstract/Concrete)
    ↓
Artefacts (Input/Output)
    ↓
Cluster Execution (PBS/LSF)
```

---

## Directory Structure

```
otp/
├── grails-app/
│   ├── controllers/           # 105 controllers (HTTP endpoints)
│   ├── services/              # 349 services (business logic)
│   ├── domain/                # 179 GORM entities
│   ├── views/                 # 236 GSP templates
│   ├── conf/                  # Configuration
│   │   ├── application.groovy # Application config
│   │   ├── runtime.groovy     # Runtime config (DB, security)
│   │   ├── logback.xml        # Logging configuration
│   │   └── CodeNarcRuleSet.groovy
│   ├── assets/                # Frontend (JS, CSS, images)
│   │   ├── javascripts/       # 93 JavaScript files
│   │   └── stylesheets/       # 33 LESS/CSS files
│   └── i18n/                  # Internationalization
├── src/
│   ├── main/groovy/           # Core business logic
│   │   └── de/dkfz/tbi/otp/   # Base package
│   │       ├── workflow/      # Workflow implementations
│   │       ├── job/           # Job scheduling
│   │       ├── utils/         # Utility classes
│   │       └── security/      # Security components
│   ├── test/groovy/           # 556 unit tests
│   ├── integration-test/      # 178 integration tests
│   └── workflow-test/         # 53 workflow tests
├── migrations/                # Liquibase changelogs
│   └── changelogs/            # Year-based organization
├── scripts/                   # Operational scripts
├── cypress/                   # E2E tests
│   └── e2e/                   # Test specifications
└── build.gradle               # Gradle build config
```

**Naming Conventions:**

- Controllers: `PascalCase + Controller` - `WorkflowRunDetailsController.groovy`
- Services: `PascalCase + Service` - `CommentService.groovy`
- Domains: `PascalCase` - `Workflow.groovy`, `Project.groovy`
- Tests: `PascalCase + Spec` - `CommentServiceSpec.groovy`
- Integration Tests: `PascalCase + IntegrationSpec`

---

## Core Principles (7 Key Rules)

### 1. Controllers Handle Requests, Services Handle Logic

```groovy
// ❌ NEVER: Business logic in controllers
class MyController {
    def action() {
        // 200 lines of database queries and business logic
        def users = User.findAll()
        users.each { /* complex processing */ }
    }
}

// ✅ ALWAYS: Delegate to services
class MyController {
    MyService myService

    def action() {
        def result = myService.performBusinessLogic()
        render result as JSON
    }
}
```

### 2. All Services Must Be @Transactional

```groovy
import grails.gorm.transactions.Transactional

@Transactional
class MyService {
    def doWork() {
        // Database operations automatically wrapped in transaction
        // Rollback on exception
    }
}
```

### 3. Domain Models Define Database Schema

```groovy
class Project {
    String name
    Date dateCreated
    Date lastUpdated

    static constraints = {
        name blank: false, unique: true, maxSize: 255
    }

    static mapping = {
        table 'project'
        version false
    }
}
```

### 4. Use GORM Dynamic Finders, NOT Raw SQL

```groovy
// ❌ AVOID: Raw SQL
def users = User.executeQuery("SELECT u FROM User u WHERE u.active = true")

// ✅ PREFER: GORM finders
def users = User.findAllByActive(true)

// ✅ PREFER: Criteria queries for complex cases
def results = User.createCriteria().list {
    eq('active', true)
    order('name', 'asc')
}
```

### 5. Secure All Controller Actions with @PreAuthorize

```groovy
import org.springframework.security.access.prepost.PreAuthorize

class AdminController {
    @PreAuthorize("hasRole('ROLE_OPERATOR')")
    def adminAction() {
        // Only operators can access
    }

    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_OPERATOR')")
    def restrictedAction() {
        // Multiple roles allowed
    }
}
```

### 6. Validate Input with Domain Constraints

```groovy
class UserCommand implements Validateable {
    String email
    String username

    static constraints = {
        email email: true, blank: false
        username blank: false, size: 3..20,
                 matches: /^[a-zA-Z0-9_]+$/
    }
}
```

### 7. Comprehensive Testing Required (Spock)

```groovy
import spock.lang.Specification
import grails.testing.gorm.DataTest

class MyServiceSpec extends Specification implements DataTest {

    void setupSpec() {
        mockDomains(User, Project)
    }

    def "test business logic"() {
        given:
        def user = new User(name: "Test").save(flush: true)

        when:
        def result = service.process(user)

        then:
        result.success
        User.count() == 1
    }
}
```

---

## Common Imports

```groovy
// Grails Core
import grails.gorm.transactions.Transactional
import grails.validation.Validateable
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.springframework.security.access.prepost.PreAuthorize

// GORM
import grails.gorm.DetachedCriteria
import org.hibernate.sql.JoinType

// HTTP Status
import static org.springframework.http.HttpStatus.*

// Testing
import spock.lang.Specification
import grails.testing.gorm.DataTest
import grails.testing.web.controllers.ControllerUnitTest
import grails.testing.services.ServiceUnitTest

// Workflow
import de.dkfz.tbi.otp.workflow.shared.OtpWorkflow
import de.dkfz.tbi.otp.workflowExecution.WorkflowRun
import de.dkfz.tbi.otp.workflowExecution.WorkflowStep

// Common Domain Models
import de.dkfz.tbi.otp.ngsdata.SeqTrack
import de.dkfz.tbi.otp.project.Project
import de.dkfz.tbi.otp.ngsdata.Individual

// Utilities
import de.dkfz.tbi.otp.utils.CollectionUtils
```

---

## Quick Reference

### HTTP Status Codes (Grails)

| Code | Grails Constant | Use Case |
|------|-----------------|----------|
| 200 | OK | Success |
| 201 | CREATED | Resource created |
| 400 | BAD_REQUEST | Invalid input |
| 401 | UNAUTHORIZED | Not authenticated |
| 403 | FORBIDDEN | No permission |
| 404 | NOT_FOUND | Resource missing |
| 500 | INTERNAL_SERVER_ERROR | Server error |

### GORM Query Methods

- `findBy*()` - Find single record
- `findAllBy*()` - Find multiple records
- `countBy*()` - Count matching records
- `listOrderBy*()` - List with ordering
- `Domain.get(id)` - Get by ID (returns null if not found)
- `Domain.load(id)` - Get proxy by ID (throws exception)
- `Domain.createCriteria()` - Complex queries
- `Domain.withCriteria {}` - Criteria builder DSL

### Reference Services

**Mature Services** (✅ Use as templates):

- `CommentService` - Simple CRUD operations
- `ProjectSelectionService` - Complex queries
- `WorkflowConfigService` - Configuration management

---

## Anti-Patterns to Avoid

- Business logic in controllers
- Direct SQL queries instead of GORM
- Missing @Transactional on services
- No domain constraints/validation
- Missing @PreAuthorize security annotations
- Mixing JUnit and Spock in same test
- Using metaClass without cleanup
- console.log instead of proper logging (use log.info/debug)
- Ignoring CodeNarc violations
- Direct file operations without FileService
- Hardcoded paths instead of ConfigService
- Missing database migrations for schema changes
- Exposing internal IDs without authorization checks
- N+1 query problems (use fetch joins)

---

## Navigation Guide

| Need to... | Read this |
|------------|-----------|
| Create UI components | [UI_development_guide.md](coding-guidelines/resources/UI_development_guide.md)
| Write tests | [testing_guide.md](coding-guidelines/resources/testing_guide.md) |
| Code review | [review_guide.md](coding-guidelines/resources/review_guide.md) |
| Static analysis | [coding_style_guide.md](coding-guidelines/resources/coding_style_guide.md) |

---

## Resource Files

### [UI_development_guide.md](coding-guidelines/resources/UI_development_guide.md)

GSP views, Bootstrap 4/5, JavaScript patterns, asset pipeline, toaster messages

### [testing_guide.md](coding-guidelines/resources/testing_guide.md)

Spock testing framework, mocking/stubbing, unit/integration/workflow tests, Cypress E2E

### [review_guide.md](coding-guidelines/resources/review_guide.md)

Code review checklist, requirements validation, testing verification, documentation

### [coding_style_guide.md](coding-guidelines/resources/coding_style_guide.md)

CodeNarc rules, ESLint configuration, static analysis, IDE setup

---

**Skill Status**: COMPLETE
**Line Count**: < 500
**Technology Stack**: Grails 6.x, Groovy 3.x, Spring Boot 3.x, GORM, PostgreSQL, Spock
