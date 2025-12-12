# Day 25 Quiz: API Testing with curl and httpie

Test your understanding of API testing tools and techniques.

## Questions

### 1. Which curl option shows detailed request/response information for debugging?
a) `-d` (data)
b) `-v` (verbose)
c) `-s` (silent)
d) `-I` (head only)

### 2. What is the httpie syntax to send a JSON POST request with a numeric value?
a) `http POST url value=123`
b) `http POST url value:=123`
c) `http POST url value==123`
d) `http POST url "value: 123"`

### 3. Which HTTP status code indicates successful resource creation?
a) 200 OK
b) 201 Created
c) 202 Accepted
d) 204 No Content

### 4. How do you set a timeout of 30 seconds with curl?
a) `--timeout 30`
b) `--max-time 30`
c) `--connect-timeout 30`
d) Both b and c are timeout-related options

### 5. What is the correct way to upload a file using httpie?
a) `http POST url file=@data.csv`
b) `http --form POST url file@data.csv`
c) `http POST url --upload data.csv`
d) `http POST url < data.csv`

### 6. Which curl option enables automatic retry on failure?
a) `--retry 3`
b) `--repeat 3`
c) `--attempt 3`
d) `--try-again 3`

### 7. How do you send a Bearer token with httpie?
a) `http GET url Bearer:TOKEN`
b) `http GET url Authorization:"Bearer TOKEN"`
c) `http GET url --auth bearer:TOKEN`
d) `http GET url Token:TOKEN`

### 8. What does the curl option `-w "%{http_code}"` do?
a) Sets the HTTP version
b) Writes the HTTP status code to output
c) Waits for the specified HTTP code
d) Filters responses by HTTP code

### 9. Which is the best practice for handling API keys in scripts?
a) Hard-code them in the script
b) Store in environment variables
c) Put them in version control
d) Pass as command line arguments

### 10. What HTTP method should you use to partially update a resource?
a) PUT
b) POST
c) PATCH
d) UPDATE

## Answers

### 1. b) `-v` (verbose)
**Explanation**: The `-v` (verbose) option shows detailed information about the request and response, including headers, SSL handshake, and connection details, making it invaluable for debugging.

### 2. b) `http POST url value:=123`
**Explanation**: In httpie, `:=` is used for non-string JSON values (numbers, booleans, objects). Regular `=` treats the value as a string.

### 3. b) 201 Created
**Explanation**: HTTP 201 Created indicates that a new resource has been successfully created. 200 OK is for successful retrieval, 202 Accepted is for async processing.

### 4. d) Both b and c are timeout-related options
**Explanation**: `--max-time` sets the total request timeout, while `--connect-timeout` sets the connection establishment timeout. Both are useful for different scenarios.

### 5. b) `http --form POST url file@data.csv`
**Explanation**: The `--form` flag tells httpie to send multipart form data, and `file@data.csv` uploads the file. Option a would send the filename as a string.

### 6. a) `--retry 3`
**Explanation**: `--retry` enables automatic retry on transient failures. You can combine it with `--retry-delay` to set the delay between attempts.

### 7. b) `http GET url Authorization:"Bearer TOKEN"`
**Explanation**: Bearer tokens are sent in the Authorization header with the "Bearer " prefix. This is the standard OAuth 2.0 format.

### 8. b) Writes the HTTP status code to output
**Explanation**: The `-w` (write-out) option with `%{http_code}` outputs the HTTP status code, useful for scripting and automation.

### 9. b) Store in environment variables
**Explanation**: Environment variables keep secrets out of code and version control while making them accessible to scripts. This is a security best practice.

### 10. c) PATCH
**Explanation**: PATCH is designed for partial updates, while PUT typically replaces the entire resource. POST creates new resources, and UPDATE is not a standard HTTP method.

## Scoring

- **8-10 correct**: Excellent! You have a strong grasp of API testing tools and HTTP fundamentals.
- **6-7 correct**: Good job! Review the areas you missed, particularly around HTTP methods and security practices.
- **4-5 correct**: You're making progress. Focus on understanding the differences between curl and httpie syntax.
- **0-3 correct**: Review the lesson material and practice with the exercises to build your foundation.

## Key Takeaways

1. **curl is universal** and powerful for scripting and automation
2. **httpie provides better UX** for interactive API exploration
3. **Verbose output** is essential for debugging API issues
4. **Proper authentication** handling keeps credentials secure
5. **HTTP status codes** provide important response information
6. **Timeout and retry logic** make scripts more robust
7. **File upload methods** vary between tools and use cases
8. **Environment variables** are the secure way to handle secrets
9. **Different HTTP methods** serve different purposes (GET, POST, PUT, PATCH, DELETE)
10. **Error handling** and logging are crucial for production API testing

## Common Patterns for Data Pipelines

- **Health checks**: Monitor API availability
- **Authentication testing**: Verify credentials and tokens
- **Data upload validation**: Test file and JSON uploads
- **Batch processing**: Test large dataset handling
- **Error scenarios**: Validate error responses and handling
- **Performance testing**: Measure response times and throughput
- **Webhook testing**: Validate callback endpoints
- **Rate limiting**: Test API limits and backoff strategies
