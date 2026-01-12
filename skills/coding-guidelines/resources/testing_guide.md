[**HOME**](Home) » [**Guidelines**](Guidelines) » [**Testing Guide**](/Guidelines/Testing-Guide)

---

## Means to keep the test duration as short as possible

- new tests should be always Spock tests
- Remove unused code
- Short-circuit domain reference chains by mocking or null. This reduces the total domain instantiation time.
- Don't write test-objects into the database, try to mock the domain objects first (avoid using the domain factory)
- Speed up filesystem access by using Java in-memory filesystem (requires use of the Path class instead of the File class) or -- at the OS level -- shared-memory filesystem (/dev/shm).
- Profile tests and identify slow tests, packages, components and operations.
  - There is a gradle scan tool to create a report of the test performance.
- Sort tests by test duration and try to reduce it (disadvantage: total test time depends on intrinsic complexity)
- Methods that are used by normal users shouldn't only tested as admin or operator or observer

## Structure for tests

- properties
  - static properties
  - services
  - ruled properties (TemporaryFolder)
  - remaining properties
- methods
  - getDomainClassesToMock
  - setup
  - cleanup
  - tests
  - abstract method
  - private helper methods
  - override methods
- help classes

## Conventions for Tests

The default testing framework in Grails is Spock. Spock's naming conventions are:

- Unit Test (classes under `test`) SHOULD end in "Spec" and MUST extend `Specification` and implements `DataTest`.
- Integration Test (classes under `integration-test`) should end in "IntegrationSpec" and MUST extend `Specification` and annotated with `@Rollback` and `@Integration`.

For "legacy" tests (JUnit), the development team agreed on the following naming conventions for tests:

- Unit tests (classes under `test`) SHOULD end in "UnitTests".
- Integration tests (classes under `integration-test`) SHOULD end in "Tests".

## E2E with Cypress

### Getting Started

For starting Cypress Tests a cypress.env.json file is needed. This file should contain the following:

```
{
  "operator_username": "otp",
  "operator_password": "otp",
  "user_username": "dave",
  "user_password": "otp",
  "departmentHead_username": "goofy",
  "departmentHead_password": "otp"
}
```

To define an individual baseUrl use the following command: `export CYPRESS_BASE_URL=https://localhost:8080`

Deactivate backdoor user, therefore modify .otp.properties

- `otp.security.useBackdoor=false`
- `otp.security.ldap.enabled=true`

#### Gradle Commands

- `./gradlew runCypressTests`: Run all Cypress tests
- `./gradlew runCypressTests -Pspec="cypress/e2e/departmentConfiguration.spec.js"` or `./gradlew runCypressTests -Dspec="cypress/e2e/departmentConfiguration.spec.js"`: run individual Test in headless browser
- `./gradlew runCypressTestsInWindow`: Open Cypress UI for testing with recordings

## Unit Testing (With Fake Objects)

### The Problem

Unit testing can be difficult since the application needs external objects, such as GORM objects (domains), which often require external resources (such as a database). In order to test the functionality of components (i.e. a `Service`) the presence of real objects is not strictly needed. Using fake objects ("mocks" or "stubs") will allow for unit tests instead of integration tests to test functionality.

The basic idea is to replace a part of the business logic with stubs that simply return results instead of doing real work. The following sections will explain how to do this (in the order of preference of the method). For a summary on the reasoning for this order, please refer to the subsection "Preferences" in the section "Best practices". Please also refer to the ["Testing" section](http://docs.grails.org/3.3.9/guide/single.html#testing) of the Grails documentation for further details.

### Mocking vs. Stubbing vs. Dummies vs. …

Mocks and Stubs are quite similar and often the term "mock" is used when "stub" is meant. This document uses the term "fake" if the difference does not matter. Simply put, mocks allow for behavior testing by providing mechanisms to inspect if methods where called (and in which order). For a playful and thorough discussion, see the articles "[The little Mocker](http://blog.8thlight.com/uncle-bob/2014/05/14/TheLittleMocker.html)" by Robert Martin (Uncle Bob) and "[Mocks Aren't Stubs](http://martinfowler.com/articles/mocksArentStubs.html)" by Martin Fowler.

### Faking with Spock

Spock should be used for all newly created tests and is also the default in Grails for some time. It comes with an [extensive documentation](https://spockframework.github.io/spock/docs/1.0/index.html) that you should consult, as it contains a lot of examples. It is recommended to at least read the [Spock Primer](https://spockframework.github.io/spock/docs/1.0/spock_primer.html) chapter, as the following sections are only a brief introduction to get you started.

It also provides its own mocking framework that is very easy to use. It should be preferred over all other methods mentioned below. The mechanisms below are described since a lot of tests are not migrated to Spock and use at least one of those listed. They should not be used in Spock tests, although they may be handy for complicated cases.

Spock provides the for types for mocking:

- Stub: Stub a class or interface complete. Only used for overwrite the result, no check about how often it is called.
- Mock: Mock a class or interface complete. Allow mocking only defined methods. All methods not overridden return null or 0
- Spy: Mock a class partially. Allow mocking only defined methods. Not mocked methods keep there origin functionality. Note: Requiring to mock parts of the class is a strong indicator of a design smell, usually a violation of the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle). It should be fixed by improving the design. If possible avoid Spy.
- GroovyMock: Mock a class or interface with Groovy support, for example mocking dynamic added methods or static methods. Note: Usually not needed. And should also avoided.
- GroovySpy: Mock a class partially with Groovy support, for example mocking dynamic added methods or static methods. Note: Same as Spy: Bad design.

#### Mocking

Mocking is the way Spock does [Interaction Based Testing](https://spockframework.github.io/spock/docs/1.0/interaction_based_testing.html). It allows you to check if some method you expect to be called in a collaborator is actually called (or not called at all). Besides, the number of invocations it allows to check for specific arguments, and the order of method calls.

Spock is a lenient mocking framework, meaning that unexpected method calls are allowed and answered with a default response in order to prevent over-specification of a test. (Which makes test brittle.) If you explicitly want to check that no other methods were called, the documentation lists a way to do that.

> **Note:** Beware that a mock is constructed in the original sense of the word, so the implementations of the methods of the collaborator are replaced with default implementations, usually returning null. If this is not what you want, you need stubbing, maybe in combination with mocking.

To create a mock, you can use one of the following syntax:

```groovy
def subscriber = Mock(Subscriber)
```

or

```groovy
Subscriber subscriber = Mock()
```

Spock's term for an assertion on a mock is interaction. An interaction is composed of a cardinality (how often a method is called) and the target and method constraint (which method on which object is called. It can optionally have an argument constraint to check if the method was called with the correct value.

```
1 * subscriber.receive("hello")
|   |          |       |
|   |          |       argument constraint
|   |          method constraint
|   target constraint
cardinality
```

A full example may look like the following: Two `Subscribers` are registered with a `Publisher` in order to be informed. If the `Publisher` sends a message, it is supposed to call the receive method on all of its Subscribers once.

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
}
```

Here, an argument constrained is used to check that the received message is equal to the input message. If the argument is no concern, an underscore (\_) can be used to ignore the passed argument(s). It is also possible to use the underscore on all other constraints. So if you do not care on which object the `receive()` method was called, you could write the above test like this:

```groovy
then:
2 * _.receive("hello")
```

Keep in mind that these are not equivalent, though. The later version would pass the test if the `reveive()` method was called twice on `subscriber` and never on `subscriber2`, or vice versa.

If you want to test if getters or setters where called, you can state them in Groovy's field syntax or explicitly in the interaction:

```groovy
1 * subscriber.status // same as: 1 * subscriber.getStatus()
```

You can mix interactions with conditions. If you do, the convention is to put interactions first, as this:

```groovy
when:
publisher.send("hello")

then:
1 * subscriber.receive("hello")
publisher.messageCount == 1
```

Besides those example, a lot of other things are possible, for example declaring the interaction at mock creation time. There are also a lot of extensions to the constraint syntax that make tests more readable. You can check all these features out in the documentation.

#### Stubbing

"Stubbing is the act of making collaborators respond to method calls in a certain way." In difference to mocking, the cardinality is not needed, since the response should be sent whenever the method is called. Otherwise, the syntax is almost the same, except for an added _response generator_ on the right side. Assuming the `receive()` method from above returns a status code when called, a stub might look like this:

```groovy
subscriber.receive(_) >> "ok"
```

This will return the constant value "ok" every time the method receive() on the subscriber object is called. As with mocking, the terminology for a stubbed interaction is almost identical:

```
subscriber.receive(_) >> "ok"
|          |       |     |
|          |       |     response generator
|          |       argument constraint
|          method constraint
target constraint
```

Declaring a stub is also mostly identical:

```groovy
def subscriber = Stub(Subscriber)
```

or

```groovy
Subscriber subscriber = Stub()
```

> **Note:** In Spock, a stub can only be used for stubbing whereas a mock can be used for mocking and stubbing. Using a stub in the declaration shows the role of that object in the test setup and should be preferred if only stubbing is needed.

A stub usually has a very limited number of interactions, so they are often declared at construction time:

```groovy
def subscriber = Stub(Subscriber) {
    receive("message1") >> "ok"
    receive("message2") >> "fail"
}
```

The above example shows that it is possible to return different values for different invocations using an argument constraint to differentiate between the two. Calling receive() with a message "message2" will always provide the "fail" status code.

It is also possible to provide sequences of return values that will return the next value in the list on each following invocation. You can use the triple-arrow operator for this:

```groovy
subscriber.receive(_) >>> ["ok", "error", "error", "ok"]
```

This will return "ok" for the first invocation, "error" for the second and third, and "ok" for all subsequent invocations. For more advanced uses, such as computing return values based on the arguments, see the documentation.

To perform side effects such as throwing an exception, use a closure:

```groovy
subscriber.receive(_) >> { throw new InternalError("ouch") }
```

Method responses can also be chained, like this:

```groovy
subscriber.receive(_) >>> ["ok", "fail", "ok"] >> { throw new InternalError() } >> "ok"
```

This will return "ok" for the first, third, fifth and all subsequent invocation, "fail" for the second, and throw an exception for the fourth.

#### Mocking and Stubbing

Sometimes, you need to combine both in order to provide a response and check for the correct invocation. As stated above, this is only possible with a mock. The interactions can be combined:

```groovy
1 * subscriber.receive("message1") >> "ok"
1 * subscriber.receive("message2") >> "fail"
```

It also means that they have to happen in the same method call. Other mocking frameworks allow for splitting the declaration of mocking and stubbing to two different places, such as a "setup" and "assert" blocks. This will **not** work with Spock, as it is a lenient mocking framework. Consult the documentation for a more detailed explanation.

### Faking via Map Coercion

> **Note:** This section is kept for legacy tests. It does not apply to Spock tests, as better mechanisms exist. (It can be used, though.)

If all you want to do is stubbing Groovy's map coercion is usually sufficient. It works by providing a map with properties and converting it to a proxy via the "as" keyword. Methods can be stubbed by using the method name as key and providing a closure with the same signature as the real method as a value. Below you will find an example that was adapted to match an example from the Grails documentation. It stubs out the `searchWeb()` method in the SearchService so that the controller (the class under test) does not have to rely on a real web search in order to be tested:

```groovy
def searchMock = [
    searchWeb: { String q -> },
] as SearchService

controller.searchService = searchMock
controller.search()
```

The drawback of this method is that it cannot be used when static methods are involved. Also, it only stubs, so it's not possible to do behavior testing. But for a lot of times stubbing is all that is needed.

### Faking via MetaClass

> **Note:** This section is kept for legacy tests. It does not apply to Spock tests, as better mechanisms exist. (It can be used, though.)

Another method is using fakes by modifying the MetaClass of an object. When used with singletons such as services, this has side effects that could break unrelated tests. It violates the principles of isolation and is discouraged. Usually one of the other methods above are sufficient. If it is used the test has to ensure to revert the changes in the tear-down.

```groovy
controller.searchService.metaClass.searchWeb = { String q -> ['first result', 'second result'] }
controller.searchService.metaClass.static.logResults = { List results -> }

controller.search()
```

When using a Spock test the annotation `@DirtiesRuntime` can be used on methods that change MetaClass. Spock will take care that the runtime is cleaned so that no side effects arise.

> **Attention:** If you change a complete class, it is necessary to clean up the changes after the test, otherwise the change stay and influence the next running test. Therefore we have an help method: `TestCase.removeMetaClass`

### Faking via Inheritance

This is the "old-school" method of faking. In this example, the service is extended and the public methods are overridden:

```groovy
class TestingSearchService extends SearchService {
    def searchWeb(String q) { ['first result', 'second result'] }
}

controller.searchService = new TestingSearchService()
controller.search()
```

This method has the drawback that it only works for public methods. To fake implementation details it's usually needed to provide a seam by making internal methods protected. Because of this using a mocking framework is usually better and more robust as it already takes care of the nasty reflection work.

### Best Practices

#### Prefer not to Spy

Most of the times, the need to spy is pointing towards a design smell. There might exist a better solution that does not require spy and that's the solution that should be preferred.

#### Preferences

The preferred way is to use the Spock framework for mocking and stubbing. You should never mix it with the Grails Mocking Framework because this may lead to unintended side effects. The same goes for `MetaClass`. If you really have to use it, also use the \`\`\`\`\`\`TestCase.removeMetaClass\`\`\` in the cleanup section.

For the JUnit tests, Map coercion is currently the most effective approach to create fake objects for testing OTP components in unit tests. If they are too limited you should choose the most appropriate approach. These would be (in order of preference):

1. Spock
   1. Mock
   2. GroovyMock
   3. Spy
   4. GroovySpy
2. Map Coercion. It's usually sufficient and the simplest method.
3. Inheritance.
4. MetaClass (with manual cleanup via `TestCase.removeMetaClass` in the cleanup section. Because of the side effects, it should be avoided.

#### Avoid GroovyTestCase

Unit tests that run in the Grails context must not extend GroovyTestCase anymore. This will cause problems. Test that do not run in the Grails context (that means tests for classes that live in `src/`) should not extend it either as it will generate a JUnit 3 test case. This does not allow the use of `TemporaryFolder`, for example. It also has other drawbacks. If you find such a test, consider re-writing it in Spock.

#### Using thrown()

In Spock, you should use `thrown()` if you expect an exception to be thrown. The method also returns the exception for further inspection.

There exist also `notThrown()` to indicate, that a test shouldn't throw an exception, and you haven't anything to check.

#### Testing custom domain constraints

Testing custom constraints can be done without any mocks since Grails provides a fake GORM layer in unit tests. The tests should not call `save()`. They should call `validate()` instead and check if the errors property is set and contains the expected values. The procedure is described with examples in the [Grails manual](https://grails.github.io/grails-doc/latest/guide/testing.html#unitTestingDomains) (subsection "testing constraints").

To simplify the check, there exist two help methods:

- TestCase.assertValidateError: check, that exact the constraint defined failed. Other failed constraints are not valid.
- TestCase.assertAtLeastExpectedValidateError: check, that at least the provided constrain fail. More failed constraints are valid.

#### Temporary test files

Test files should be created using `TemporaryFolder`. It provides a unique base directory and takes care of clean-up. See the [JUnit documentation](https://github.com/junit-team/junit/wiki/Rules#temporaryfolder-rule) for more information.

```
    @Rule
    TemporaryFolder temporaryFolder
```

> **Note:** This does not work with JUnit 3 tests, that is tests extending GroovyTestCase or using a mixin. Consider re-writing those.

### Recommended Reading/Watching

#### Books

- Michael Feathers: Working Effectively with Legacy Code
- Jay Fields: Working Effectively with Unit Tests
- Freeman & Price: Growing Object-Oriented Software, Guided by Tests (GOOS)
- Kent Beck: Test-Driven Development. By Example.

#### Articles

- Robert Martin: [The little Mocker](http://blog.8thlight.com/uncle-bob/2014/05/14/TheLittleMocker.html)
- Martin Fowler: [Mocks Aren't Stubs](http://martinfowler.com/articles/mocksArentStubs.html)

#### Videos (Talks)

- Gary Bernhard: [Boundaries](https://www.destroyallsoftware.com/talks/boundaries)
