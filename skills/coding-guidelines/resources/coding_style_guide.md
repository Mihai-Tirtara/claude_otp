[**HOME**](Home) » [**Guidelines**](Guidelines) » [**Coding Style Guide**](/Guidelines/Coding-Style-Guide)



---

# Coding style

## Codenarc

The codeStyles are defined in codeNarc, which is configured in the project itself.

- Codenarc general: https://codenarc.org/codenarc-rule-index.html
- Own CodeNarc rules: https://gitlab.com/one-touch-pipeline/otp/-/tree/master/grails-app/codenarcRules
- Active rules with priority: https://gitlab.com/one-touch-pipeline/otp/-/blob/master/grails-app/conf/CodeNarcRuleSet.groovy

To run CodeNarc check and print violations on the console and report use `./gradlew codenarcAll`.

The report is located in the project under `build/reports/codenarc`

## EsLint

To activate EsLint plugin in IntelliJ:

* run `./gradlew npmInstall` at least ones
* go to the settings `Languages & Frameworks > JavaScript > Code Quality Tools > EsLint` and check _Automatic EsLint configuration_
* check the settings of Node.js in settings `Languages & Frameworks > Node.js and NPM`

### Gradle Tasks

* `./gradlew esLint` to print EsLint errors and warnings in console
* `./gradlew esLintAutoFix` to use autofixes from EsLint (prefer-template rule is ignored)
* `./gradlew esLintExport` to create a report with the EsLint errors and warnings which is located in build/reports/eslint/lint.html

### Npm Commands with gradle:

* `/.gradlew npm_run_lint` to print EsLint errors and warnings in console `/.gradlew npm_run_lint-export` to create a report with the EsLint errors and warnings which is located in build/reports/eslint/lint.html
* `/.gradlew npm_run_lint-fix --rule "prefer-template:0"` to use autofixes from EsLint. We had to exclude prefer-template rule, cause it destroys some code.

