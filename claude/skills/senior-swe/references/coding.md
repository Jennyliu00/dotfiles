# Coding Best Practices Reference

## Go Programming Best Practices

### Code Organization

**Package Structure**:
```
project/
├── cmd/           # Main applications
├── internal/      # Private application code
├── pkg/           # Public library code
├── api/           # API definitions (protobuf, OpenAPI)
├── configs/       # Configuration files
├── deployments/   # Deployment manifests
└── scripts/       # Build and utility scripts
```

**Naming Conventions**:
- **Packages**: Short, lowercase, no underscores (e.g., `http`, `auth`, `datastore`)
- **Files**: Lowercase with underscores (e.g., `user_handler.go`, `auth_service_test.go`)
- **Interfaces**: Noun or agent noun (e.g., `Reader`, `Writer`, `Handler`)
- **Functions**: MixedCaps (e.g., `GetUser`, `ProcessRequest`)
- **Constants**: MixedCaps or ALL_CAPS for exported (e.g., `MaxRetries`, `DEFAULT_TIMEOUT`)

### Error Handling

**Always return errors**:
```go
// ✅ Good
func ProcessData(data []byte) (*Result, error) {
    if len(data) == 0 {
        return nil, errors.New("empty data")
    }
    // ...
}

// ❌ Bad
func ProcessData(data []byte) *Result {
    if len(data) == 0 {
        return nil  // Silent failure
    }
    // ...
}
```

**Wrap errors with context**:
```go
// ✅ Good
result, err := database.Query(ctx, query)
if err != nil {
    return fmt.Errorf("failed to query database: %w", err)
}

// ❌ Bad
result, err := database.Query(ctx, query)
if err != nil {
    return err  // Lost context
}
```

**Handle errors immediately**:
```go
// ✅ Good
file, err := os.Open(filename)
if err != nil {
    return fmt.Errorf("open file: %w", err)
}
defer file.Close()

// ❌ Bad
file, _ := os.Open(filename)  // Ignoring error
defer file.Close()
```

### Concurrency

**Use channels for synchronization**:
```go
// ✅ Good
func worker(jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        results <- process(job)
    }
}
```

**Always close channels when done**:
```go
jobs := make(chan Job)
go func() {
    defer close(jobs)  // ✅ Always close
    for _, job := range jobList {
        jobs <- job
    }
}()
```

**Use WaitGroup for multiple goroutines**:
```go
var wg sync.WaitGroup
for i := 0; i < 10; i++ {
    wg.Add(1)
    go func(n int) {
        defer wg.Done()
        process(n)
    }(i)
}
wg.Wait()
```

**Respect context cancellation**:
```go
func Process(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()  // ✅ Handle cancellation
        default:
            // Do work
        }
    }
}
```

### Resource Management

**Always use defer for cleanup**:
```go
// ✅ Good
func ReadFile(filename string) ([]byte, error) {
    file, err := os.Open(filename)
    if err != nil {
        return nil, err
    }
    defer file.Close()  // ✅ Guaranteed cleanup

    return io.ReadAll(file)
}
```

**Close resources in reverse order of creation**:
```go
db, err := sql.Open(driver, dsn)
if err != nil {
    return err
}
defer db.Close()

tx, err := db.Begin()
if err != nil {
    return err
}
defer tx.Rollback()  // Safe to call even after commit

// ... work with tx ...

return tx.Commit()
```

### Testing

**Table-driven tests**:
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 2, 3, 5},
        {"negative", -1, -2, -3},
        {"zero", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d, want %d",
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

**Use testify for assertions**:
```go
import "github.com/stretchr/testify/assert"

func TestGetUser(t *testing.T) {
    user, err := GetUser(123)
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, "John", user.Name)
}
```

**Test error cases**:
```go
func TestGetUser_NotFound(t *testing.T) {
    user, err := GetUser(999)
    assert.Error(t, err)
    assert.Nil(t, user)
    assert.Contains(t, err.Error(), "not found")
}
```

### Performance

**Use sync.Pool for frequently allocated objects**:
```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func Process() {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer bufferPool.Put(buf)
    buf.Reset()
    // Use buffer...
}
```

**Preallocate slices when size is known**:
```go
// ✅ Good
items := make([]Item, 0, expectedSize)

// ❌ Bad - causes multiple reallocations
var items []Item
for range largeList {
    items = append(items, ...)
}
```

**Use string builder for concatenation**:
```go
// ✅ Good
var builder strings.Builder
for _, s := range strings {
    builder.WriteString(s)
}
result := builder.String()

// ❌ Bad - creates many intermediate strings
result := ""
for _, s := range strings {
    result += s
}
```

## Clean Code Principles

### SOLID Principles

**Single Responsibility**:
```go
// ✅ Good - each struct has one responsibility
type UserRepository struct {
    db *sql.DB
}

type UserValidator struct {
    rules []ValidationRule
}

type UserService struct {
    repo      *UserRepository
    validator *UserValidator
}
```

**Open/Closed**:
```go
// ✅ Good - extensible without modification
type Handler interface {
    Handle(ctx context.Context, req Request) (Response, error)
}

type LoggingHandler struct {
    next Handler
}

type MetricsHandler struct {
    next Handler
}
```

**Dependency Inversion**:
```go
// ✅ Good - depend on abstractions
type UserService struct {
    repo UserRepository  // Interface, not concrete type
}

type UserRepository interface {
    Get(ctx context.Context, id string) (*User, error)
}
```

### Naming

**Be descriptive**:
```go
// ✅ Good
userAuthenticationToken := generateToken()
maxRetryAttempts := 3

// ❌ Bad
uat := generateToken()
max := 3
```

**Use verbs for functions**:
```go
// ✅ Good
func CalculateTotal() int
func ValidateInput() error
func SendEmail() error

// ❌ Bad
func Total() int
func Input() error
func Email() error
```

**Boolean variables should be questions**:
```go
// ✅ Good
isActive := true
hasPermission := checkPermission()
canEdit := user.IsAdmin

// ❌ Bad
active := true
permission := checkPermission()
edit := user.IsAdmin
```

### Functions

**Keep functions small**:
- Single responsibility
- One level of abstraction
- Typically 20-30 lines max
- If > 50 lines, consider splitting

**Limit parameters**:
```go
// ✅ Good
type UserCreateOptions struct {
    Name     string
    Email    string
    Role     string
    IsActive bool
}

func CreateUser(opts UserCreateOptions) (*User, error)

// ❌ Bad - too many parameters
func CreateUser(name, email, role string, isActive bool) (*User, error)
```

**Return early**:
```go
// ✅ Good
func Process(data []byte) error {
    if len(data) == 0 {
        return ErrEmptyData
    }

    if !isValid(data) {
        return ErrInvalidData
    }

    // Main logic here
    return nil
}

// ❌ Bad - nested conditions
func Process(data []byte) error {
    if len(data) > 0 {
        if isValid(data) {
            // Main logic deeply nested
            return nil
        }
        return ErrInvalidData
    }
    return ErrEmptyData
}
```

### Comments

**Write self-documenting code**:
```go
// ✅ Good - code explains itself
func isEligibleForDiscount(user User) bool {
    return user.PurchaseCount > 10 && user.AccountAge > 365
}

// ❌ Bad - comment needed to explain
// Returns true if user should get discount
func check(u User) bool {
    return u.PC > 10 && u.AA > 365
}
```

**Comment the "why", not the "what"**:
```go
// ✅ Good
// Wait 10 seconds to allow in-flight requests to complete
// before shutting down the server
time.Sleep(10 * time.Second)

// ❌ Bad
// Sleep for 10 seconds
time.Sleep(10 * time.Second)
```

**Document public APIs**:
```go
// ✅ Good
// GetUser retrieves a user by ID from the database.
// Returns ErrNotFound if the user doesn't exist.
func GetUser(ctx context.Context, id string) (*User, error)
```

## Security Best Practices

### Input Validation

**Validate at boundaries**:
```go
func CreateUser(input UserInput) (*User, error) {
    // ✅ Validate immediately
    if err := input.Validate(); err != nil {
        return nil, fmt.Errorf("invalid input: %w", err)
    }

    // Trust validated data internally
    return userService.Create(input)
}
```

**Use parameterized queries**:
```go
// ✅ Good
query := "SELECT * FROM users WHERE id = $1"
row := db.QueryRow(query, userID)

// ❌ Bad - SQL injection vulnerability
query := fmt.Sprintf("SELECT * FROM users WHERE id = %s", userID)
```

**Sanitize output**:
```go
import "html/template"

// ✅ Good - auto-escapes HTML
tmpl.Execute(w, template.HTML(userInput))

// ❌ Bad - XSS vulnerability
fmt.Fprintf(w, "<div>%s</div>", userInput)
```

### Secrets Management

**Never hardcode secrets**:
```go
// ✅ Good
apiKey := os.Getenv("API_KEY")

// ❌ Bad
apiKey := "sk-1234567890abcdef"
```

**Use secret management services**:
- AWS Secrets Manager
- HashiCorp Vault
- Kubernetes Secrets
- 1Password / LastPass for development

## Code Quality Tools

### Linting

**golangci-lint** - comprehensive linter:
```bash
golangci-lint run --enable-all
```

**Common linters**:
- `errcheck` - Unchecked errors
- `govet` - Suspicious constructs
- `staticcheck` - Advanced analysis
- `gosec` - Security issues
- `gocyclo` - Cyclomatic complexity

### Formatting

**goimports** - format + import management:
```bash
goimports -w .
```

**gofmt** - standard formatter:
```bash
gofmt -s -w .
```

### Testing

**go test** with coverage:
```bash
go test -v -race -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

**Benchmarking**:
```bash
go test -bench=. -benchmem
```

## Additional Resources

- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
- [Clean Code (Robert C. Martin)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
- [The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)
