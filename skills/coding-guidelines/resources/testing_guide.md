# Testing Guide - Grails/Spock Testing Strategies

Complete guide to testing OTP services with Spock and best practices for Grails applications.

## Table of Contents

- [Test Naming Conventions](#test-naming-conventions)
- [Test Structure](#test-structure)
- [Unit Testing with Spock](#unit-testing-with-spock)
- [Integration Testing](#integration-testing)
- [Mocking and Stubbing](#mocking-and-stubbing)
- [E2E Testing with Cypress](#e2e-testing-with-cypress)
- [Performance Optimization](#performance-optimization)
- [Best Practices](#best-practices)

---

## Test Naming Conventions

### Spock Tests (Default Framework)

- **Unit Test** (classes under `test/`): SHOULD end in `Spec` and MUST extend `Specification` and implement `DataTest`
- **Integration Test** (classes under `integration-test/`): SHOULD end in `IntegrationSpec` and MUST extend `Specification` and be annotated with `@Rollback` and `@Integration`

### Legacy JUnit Tests

- **Unit tests** (classes under `test/`): SHOULD end in `UnitTests`
- **Integration tests** (classes under `integration-test/`): SHOULD end in `Tests`

> **Note:** All new tests should be Spock tests, not JUnit.

---

## Test Structure

### Recommended Test Organization

```groovy
class MyServiceSpec extends Specification implements DataTest {
    // 1. Static properties
    static final String TEST_CONSTANT = "value"

    // 2. Services and dependencies
    MyService service
    OtherService otherService = Mock()

    // 3. Ruled properties (TemporaryFolder)
    @Rule
    TemporaryFolder temporaryFolder

    // 4. Remaining properties
    String testData

    // 5. getDomainClassesToMock
    Class[] getDomainClassesToMock() {
        [User, Project]
    }

    // 6. setup
    def setup() {
        service = new MyService()
        service.otherService = otherService
    }

    // 7. cleanup
    def cleanup() {
        // Clean up resources
    }

    // 8. Test methods
    def "should perform action when condition is met"() {
        given:
        // Setup

        when:
        // Execute

        then:
        // Verify
    }

    // 9. Private helper methods
    private createTestUser() {
        new User(username: "test")
    }
}
```

---

## Unit Testing with Spock

### Basic Unit Test Example

```groovy
import spock.lang.Specification
import grails.testing.services.ServiceUnitTest

class UserServiceSpec extends Specification implements ServiceUnitTest<UserService> {

    def "should create user when email is unique"() {
        given: "a unique email"
        String email = "test@example.com"
        User user = new User(username: "testuser", email: email)

        and: "no existing user with that email"
        service.userRepository = Mock(UserRepository) {
            findByEmail(email) >> null
            save(_) >> user
        }

        when: "creating a new user"
        User result = service.createUser(email, "testuser")

        then: "user is created successfully"
        result != null
        result.email == email
        result.username == "testuser"
    }

    def "should throw exception when email already exists"() {
        given: "an existing email"
        String email = "existing@example.com"

        and: "user already exists with that email"
        service.userRepository = Mock(UserRepository) {
            findByEmail(email) >> new User(email: email)
        }

        when: "trying to create user with same email"
        service.createUser(email, "newuser")

        then: "exception is thrown"
        thrown(IllegalArgumentException)
    }
}
```

### Testing Domain Constraints

```groovy
import grails.testing.gorm.DataTest

class UserSpec extends Specification implements DataTest {

    Class[] getDomainClassesToMock() {
        [User]
    }

    def "should validate email format"() {
        when: "creating user with invalid email"
        User user = new User(username: "test", email: "invalid-email")
        user.validate()

        then: "email validation fails"
        user.hasErrors()
        user.errors.getFieldError('email')
    }

    def "should require unique username"() {
        given: "existing user"
        new User(username: "existing", email: "test@test.com").save(flush: true)

        when: "creating user with same username"
        User duplicate = new User(username: "existing", email: "other@test.com")
        duplicate.validate()

        then: "unique constraint fails"
        !duplicate.validate()
        duplicate.errors.getFieldError('username').code == 'unique'
    }
}
```

---

## Integration Testing

### Integration Test Example

```groovy
import grails.testing.mixin.integration.Integration
import grails.gorm.transactions.Rollback
import spock.lang.Specification

@Integration
@Rollback
class UserServiceIntegrationSpec extends Specification {

    UserService userService

    def "should persist user to database"() {
        when: "creating a new user"
        User user = userService.createUser("test@example.com", "testuser")

        then: "user is saved to database"
        user.id != null
        User.count() == 1
        User.findByEmail("test@example.com") != null
    }

    def "should handle transactions correctly"() {
        given: "initial user count"
        int initialCount = User.count()

        when: "creating multiple users in transaction"
        User.withTransaction {
            userService.createUser("user1@test.com", "user1")
            userService.createUser("user2@test.com", "user2")
        }

        then: "all users are persisted"
        User.count() == initialCount + 2
    }
}
```

---

## Mocking and Stubbing

Spock provides powerful mocking and stubbing capabilities. Understanding when and how to use each type is essential for writing effective tests.

### Overview

- **Mock vs. Stub**: Mocks allow behavior testing (verifying method calls), while stubs simply return predefined values
- Use mocking to verify interactions between components
- Use stubbing to isolate the code under test from dependencies

### Spock Mock Types

| Type | Purpose | When to Use | Avoid Because |
|------|---------|-------------|---------------|
| **Mock** | Full mock with verification | Verify method calls and return values | - |
| **Stub** | Return predefined values | Isolate dependencies without verification | - |
| **Spy** | Partial mock (real methods + mocked) | Testing legacy code | Usually indicates design smell (SRP violation) |
| **GroovyMock** | Mock with Groovy dynamic features | Mocking static/dynamic methods | Rarely needed |
| **GroovySpy** | Partial mock with Groovy features | Same as Spy with Groovy support | Design smell |

> **Recommendation:** Use **Mock** and **Stub**. Avoid **Spy**, **GroovyMock**, and **GroovySpy** unless absolutely necessary.

### Creating Mocks

```groovy
// Type inference
def subscriber = Mock(Subscriber)

// Explicit type
Subscriber subscriber = Mock()

// Mock with interactions at creation
def subscriber = Mock(Subscriber) {
    receive("hello") >> "ok"
}
```

### Interaction Syntax

Spock uses **interactions** to verify method calls:

```
1 * subscriber.receive("hello")
|   |          |       |
|   |          |       argument constraint
|   |          method constraint
|   target constraint
cardinality
```

### Mocking Example

```groovy
class PublisherSpec extends Specification {
    Publisher publisher = new Publisher()
    Subscriber subscriber = Mock()
    Subscriber subscriber2 = Mock()

    def setup() {
        publisher.subscribers << subscriber
        publisher.subscribers << subscriber2
    }

    def "should send messages to all subscribers"() {
        when:
        publisher.send("hello")

        then:
        1 * subscriber.receive("hello")
        1 * subscriber2.receive("hello")
    }

    def "should send to any subscriber"() {
        when:
        publisher.send("hello")

        then:
        2 * _.receive("hello")  // Any object, called twice
    }

    def "should track property access"() {
        when:
        def status = subscriber.status

        then:
        1 * subscriber.status  // Same as: subscriber.getStatus()
    }

    def "should combine interactions and assertions"() {
        when:
        publisher.send("hello")

        then:
        1 * subscriber.receive("hello")
        publisher.messageCount == 1
    }
}
```

### Stubbing

Stubbing provides return values without verifying interactions.

```groovy
// Basic stubbing
subscriber.receive(_) >> "ok"

// Create stubs
def repository = Stub(UserRepository)
UserRepository repository = Stub()

// Stub at creation time
def repository = Stub(UserRepository) {
    findByEmail("test@test.com") >> testUser
    findByEmail("other@test.com") >> null
}
```

**Stub interaction anatomy:**

```
subscriber.receive(_) >> "ok"
|          |       |     |
|          |       |     response generator
|          |       argument constraint
|          method constraint
target constraint
```

### Advanced Stubbing Techniques

```groovy
// Return sequences
subscriber.receive(_) >>> ["ok", "error", "error", "ok"]
// Returns: "ok", "error", "error", "ok", "ok", "ok", ...

// Throw exceptions
subscriber.receive(_) >> { throw new IllegalArgumentException("Invalid") }

// Chain responses
subscriber.receive(_) >>> ["ok", "fail"] >> { throw new InternalError() } >> "ok"
// Returns: "ok", "fail", throws exception, "ok", "ok", ...

// Compute return values
calculator.add(_, _) >> { a, b -> a + b }
```

### Combining Mocking and Stubbing

Mocks can verify interactions AND return values:

```groovy
def "should process messages with different responses"() {
    given:
    def processor = Mock(MessageProcessor)

    when:
    service.processMessages(processor)

    then:
    1 * processor.receive("message1") >> "ok"
    1 * processor.receive("message2") >> "fail"
}
```

> **Important:** Spock is lenient. Mocking and stubbing must be declared in the same `then:` block, not split between setup and assertions.

### Legacy Mocking Approaches

> **Note:** These are kept for reference only. **Use Spock mocking for all new tests.**

#### Map Coercion (Legacy)

```groovy
def searchMock = [
    searchWeb: { String q -> [] }
] as SearchService

controller.searchService = searchMock
controller.search()
```

**Limitations:** Cannot mock static methods, no behavior verification.

#### MetaClass (Legacy - Avoid)

```groovy
// Modify MetaClass
controller.searchService.metaClass.searchWeb = { String q -> ['result1', 'result2'] }
controller.searchService.metaClass.static.logResults = { List results -> }

// MUST clean up in cleanup() or use @DirtiesRuntime
```

> **Warning:** MetaClass modifications have side effects. Use `TestCase.removeMetaClass` in cleanup or `@DirtiesRuntime` annotation.

#### Inheritance (Legacy)

```groovy
class TestSearchService extends SearchService {
    def searchWeb(String q) { ['result1', 'result2'] }
}

controller.searchService = new TestSearchService()
```

**Limitation:** Only works for public methods.

---

## E2E Testing with Cypress

### Setup

Create `cypress.env.json` with test credentials:

```json
{
  "operator_username": "otp",
  "operator_password": "otp",
  "user_username": "dave",
  "user_password": "otp",
  "departmentHead_username": "goofy",
  "departmentHead_password": "otp"
}
```

### Configuration

```bash
# Set custom base URL
export CYPRESS_BASE_URL=https://localhost:8080
```

**Modify `.otp.properties` for testing:**

```properties
otp.security.useBackdoor=false
otp.security.ldap.enabled=true
```

### Running Cypress Tests

```bash
# Run all tests (headless)
./gradlew runCypressTests

# Run specific test (headless)
./gradlew runCypressTests -Pspec="cypress/e2e/departmentConfiguration.spec.js"
./gradlew runCypressTests -Dspec="cypress/e2e/departmentConfiguration.spec.js"

# Open Cypress UI
./gradlew runCypressTestsInWindow
```


### TemporaryFolder for Test Files

```groovy
@Rule
TemporaryFolder temporaryFolder

def "should create temporary files"() {
    given:
    File testFile = temporaryFolder.newFile("test.txt")

    when:
    testFile.text = "test content"

    then:
    testFile.exists()
    testFile.text == "test content"
}
// Automatic cleanup after test
```

---

## Best Practices

### Mocking Framework Preferences

**Order of preference:**

1. **Spock** (Primary)
    - Mock
    - Stub
    - GroovyMock (only for static/dynamic methods)
    - Spy (avoid - indicates design smell)
    - GroovySpy (avoid - design smell)
2. **Map Coercion** (Legacy only)
3. **Inheritance** (Legacy only)
4. **MetaClass** (Avoid - side effects)

> **Never mix Spock with other mocking frameworks** - Can cause unintended side effects. If you must use MetaClass, clean up with `TestCase.removeMetaClass` in the cleanup section.

### Exception Testing

```groovy
def "should throw exception when invalid input"() {
    when:
    service.processInvalidData()

    then:
    IllegalArgumentException ex = thrown()
    ex.message == "Invalid data"
}

def "should not throw exception when valid input"() {
    when:
    service.processValidData()

    then:
    notThrown()
}
```

### Testing Domain Constraints

```groovy
def "should validate custom constraints"() {
    when:
    User user = new User(email: "invalid")
    user.validate()  // Don't use save()

    then:
    user.hasErrors()
    user.errors.getFieldError('email').code == 'email.invalid'
}
```

**Helper methods:**

- `TestCase.assertValidateError` - Exact constraint must fail
- `TestCase.assertAtLeastExpectedValidateError` - At least specified constraints fail

See [Grails Testing Domains](https://grails.github.io/grails-doc/latest/guide/testing.html#unitTestingDomains) for more details.

### Avoid GroovyTestCase

- **Do not extend `GroovyTestCase`** - Causes JUnit 3 issues
- **Rewrite in Spock** - Better tooling and features
- `TemporaryFolder` doesn't work with JUnit 3

### Prefer Not to Spy

> Needing Spy usually indicates a **design smell** (violates Single Responsibility Principle). Refactor instead.

---

**Related Documentation:**
- [Grails Testing](http://docs.grails.org/3.3.9/guide/single.html#testing)
- [Spock Framework](https://spockframework.github.io/spock/docs/1.0/index.html)
- [Spock Primer](https://spockframework.github.io/spock/docs/1.0/spock_primer.html)
- [JUnit Rules](https://github.com/junit-team/junit/wiki/Rules#temporaryfolder-rule)
