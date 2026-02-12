
<a name="top" />

[**HOME**](Home) » [**Guidelines**](Guidelines) » [**Review Guide**](/Guidelines/Review-Guide)


***

***

# 1. Understand Issue & Requirements:
- read Issue description
- make sure requirements to the software have been understood before moving on
- check the complexity estimate. Every issue in the Sprint must be estimated in a team-meeting. Watch out for features not described in the issue or recent changes to the issue (after the last estimate) that make a re-estimation.

# 2. Look through the code changes (e.g. git side-by-side view):
- understand the code 
- any logical errors?
- intention over code style, expressibility, readability ok?
- completeness: requirements only partially fulfilled? solution to the problem/issue implemented?
- implicit code assumptions?
- any DB redundancy? constraints useful and complete?
- code comments: available, understandable, up to date?
- maintainability: can the code be reused? is it generalized?
- any safety concerns?
- unnecessary code duplication?
- git message understandable, representing the issue/implementation?
- don't forget to give compliments for things which are good!
- watch out for new dead code -- dead-code removal is part of the implementation

# 3. Look at the Unit/IntegrationTests
- run workflow tests if changes affect any
  - manually check test outputs on the file system
- check for uncovered test cases
- negative test case included?
- clean up of tests

# 4. Look at the Database migration
- make sure scripts work on different locations, if
  - add/update constraints to existing columns
  - moving of data because of restructuring the database

# 5. Test functionality on the GUI
- think also about user-friendliness!
- all pages that may be affected are checked manually that they work as normal user (not only as admin user)
- check that users *don't* have access to admin-only pages

# 6. Check CodeNarc
- try to avoid new type 2 errors; mark (@SUPRESSWARNING) if really necessary
- try to avoid new type 3 errors; use IntelliJ to spot code style improvements
- use "insert suggestion" functionality in git for minor things

# 7. Documentation

- code is documented (meaning of new terms, non-trivial interactions of classes, architecture)
- What do the classes/methods do? 
- How do classes interact?

