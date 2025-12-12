# Day 23 Quiz: Automated Testing Strategies

Test your understanding of automated testing concepts and best practices.

## Question 1: Testing Pyramid
According to the testing pyramid, which type of tests should you have the most of?

A) End-to-end tests  
B) Integration tests  
C) Unit tests  
D) Performance tests  

<details>
<summary>Answer</summary>

**C) Unit tests**

The testing pyramid suggests having many unit tests (fast, isolated), some integration tests, and few end-to-end tests (slow, complex).
</details>

---

## Question 2: pytest Fixtures
What is the primary purpose of pytest fixtures?

A) To run tests faster  
B) To provide reusable test setup and data  
C) To generate test reports  
D) To mock external services  

<details>
<summary>Answer</summary>

**B) To provide reusable test setup and data**

Fixtures provide a way to set up test data, database connections, or other resources that can be reused across multiple tests.
</details>

---

## Question 3: Test Coverage
What does 80% test coverage mean?

A) 80% of tests are passing  
B) 80% of the code is executed by tests  
C) Tests run 80% faster  
D) 80% of bugs are caught  

<details>
<summary>Answer</summary>

**B) 80% of the code is executed by tests**

Test coverage measures the percentage of code lines/branches that are executed when running the test suite.
</details>

---

## Question 4: Parameterized Tests
What is the benefit of using `@pytest.mark.parametrize`?

A) Tests run in parallel  
B) Tests run faster  
C) One test function can test multiple input combinations  
D) Tests are automatically mocked  

<details>
<summary>Answer</summary>

**C) One test function can test multiple input combinations**

Parameterized tests allow you to run the same test logic with different input values, reducing code duplication and improving test coverage.
</details>

---

## Question 5: Mocking
When should you use mocking in tests?

A) Always, for all dependencies  
B) Never, tests should be realistic  
C) For external dependencies and slow operations  
D) Only for database connections  

<details>
<summary>Answer</summary>

**C) For external dependencies and slow operations**

Mocking is useful for isolating tests from external services, databases, or slow operations that would make tests unreliable or slow.
</details>

---

## Question 6: API Testing
Which HTTP status code should a health check endpoint return when the service is healthy?

A) 201  
B) 200  
C) 204  
D) 202  

<details>
<summary>Answer</summary>

**B) 200**

HTTP 200 (OK) is the standard status code for successful requests, including health checks that confirm the service is operating normally.
</details>

---

## Question 7: Performance Testing
What should you verify in performance tests besides execution time?

A) Only that the function completes  
B) That the result is correct and performance meets thresholds  
C) Only memory usage  
D) Only CPU usage  

<details>
<summary>Answer</summary>

**B) That the result is correct and performance meets thresholds**

Performance tests should verify both correctness (the function produces the right result) and performance (it meets speed/resource requirements).
</details>

---

## Question 8: Test Organization
How should you organize tests in a large project?

A) All tests in one file  
B) Separate directories for unit, integration, and e2e tests  
C) One test file per source file  
D) Random organization  

<details>
<summary>Answer</summary>

**B) Separate directories for unit, integration, and e2e tests**

Organizing tests by type (unit, integration, e2e) makes it easier to run specific test categories and understand the test structure.
</details>

---

## Question 9: CI/CD Integration
At what point in the CI/CD pipeline should tests run?

A) Only before deployment to production  
B) After every code change (push/PR)  
C) Once per week  
D) Only when bugs are reported  

<details>
<summary>Answer</summary>

**B) After every code change (push/PR)**

Tests should run automatically after every code change to provide immediate feedback and catch issues early in the development process.
</details>

---

## Question 10: Test Data Management
What's the best practice for managing test data?

A) Use production data directly  
B) Create fixtures with known, controlled test data  
C) Generate random data every time  
D) Hard-code data in each test  

<details>
<summary>Answer</summary>

**B) Create fixtures with known, controlled test data**

Fixtures with controlled, predictable test data ensure tests are reliable and repeatable, while avoiding the risks of using production data.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand automated testing well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with test creation.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Practical Challenge

Design a test strategy for this scenario:

**Application**: Data processing API with ML model training
**Components**: 
- Data validation functions
- Statistical analysis functions
- ML model training pipeline
- REST API endpoints
- Database operations

**Test Strategy Solution:**

```python
# Unit Tests (70% of tests)
class TestDataValidation:
    def test_validate_required_fields(self):
        # Test individual validation functions
        pass
    
    def test_data_type_validation(self):
        # Test data type checking
        pass

class TestStatisticalFunctions:
    def test_mean_calculation(self):
        # Test statistical calculations
        pass
    
    @pytest.mark.parametrize("data,expected", [...])
    def test_outlier_detection(self, data, expected):
        # Test outlier detection with various inputs
        pass

# Integration Tests (25% of tests)
class TestAPIEndpoints:
    def test_data_processing_workflow(self):
        # Test complete data processing flow
        pass
    
    def test_database_integration(self):
        # Test database operations
        pass

class TestMLPipeline:
    def test_training_pipeline(self):
        # Test complete ML training workflow
        pass

# Performance Tests (5% of tests)
class TestPerformance:
    def test_large_dataset_processing(self):
        # Test with large datasets
        pass
    
    def test_concurrent_api_requests(self):
        # Test API under load
        pass
```

**Key Principles:**
- Test each component in isolation (unit tests)
- Test component interactions (integration tests)
- Test performance with realistic data sizes
- Mock external dependencies
- Use fixtures for reusable test data
- Integrate with CI/CD for continuous feedback

## Next Steps

Tomorrow (Day 24) we'll learn package management and dependency handling, building on these testing foundations to create maintainable applications.

## Key Takeaways

- Automated testing provides quality assurance and regression prevention
- The testing pyramid guides test distribution and strategy
- pytest provides powerful testing capabilities with fixtures and parameterization
- Data science testing requires attention to data validation and model performance
- API testing ensures endpoints work correctly under various conditions
- Performance testing catches scalability issues early
- Mocking enables isolated testing of components
- CI/CD integration provides continuous feedback on code quality
