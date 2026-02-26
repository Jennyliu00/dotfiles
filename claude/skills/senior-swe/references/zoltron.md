# Zoltron Codebase Reference

## Overview

**Location**: `~/go/src/github.com/DataDog/dd-source/domains/aaa/apps/zoltron`

Zoltron is a three-flavor microservice providing granular access control for DataDog:

1. **Control Plane (HTTP)** - REST API for managing policies and datasets
2. **Data Plane (gRPC)** - High-performance authorization checks
3. **Provider Service (gRPC)** - Feeds snapshots to the Frames cache

## Architecture Patterns

### Repository Pattern

**Location**: `internal/datastore/`

Interface-based data access with separate read/write paths:

```go
type Repository interface {
    Get(ctx context.Context, id string) (*Model, error)
    List(ctx context.Context, filters Filters) ([]*Model, error)
    Create(ctx context.Context, model *Model) error
    Update(ctx context.Context, model *Model) error
    Delete(ctx context.Context, id string) error
}
```

**Key features**:
- Dual-reader pattern for shadow caching (migrate from DB to Frames)
- Automatic span creation for tracing
- Metrics reporting per operation
- Context management with timeouts

### Handler Pattern

**Location**: `internal/http/` and `internal/grpc/`

Decorators wrapping business logic:

```go
func HandlerWithTracing(handler Handler) Handler {
    return func(ctx context.Context, req Request) (Response, error) {
        span := trace.StartSpan(ctx, "handler")
        defer span.End()
        return handler(ctx, req)
    }
}
```

**Decorator stack**:
1. Tracing
2. Metrics
3. Error handling
4. Validation
5. Business logic

### Database Access Pattern

**`dbBase` pattern** - Standard database wrapper:

```go
type dbBase struct {
    db     *sql.DB
    tracer trace.Tracer
    meter  metric.Meter
}

func (d *dbBase) Query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
    span := d.tracer.StartSpan(ctx, "db.query")
    defer span.End()

    start := time.Now()
    rows, err := d.db.QueryContext(ctx, query, args...)
    d.meter.RecordDuration("db.query.duration", time.Since(start))

    return rows, err
}
```

### Relation Tuples

**Core authorization model**:

```
subject:object#relation
```

**Principals**:
- `org:<uuid>` - Organization access
- `user:<uuid>` - User access
- `role:<name>` - Role-based access
- `team:<uuid>` - Team access
- `tagged_teams:<tag>` - Conditional team access

**Example tuples**:
```
user:123:dataset:rum#viewer
org:456:restriction-policy:789#owner
tagged_teams:sre:monitor:alerts#editor
```

### Authorization Logic

**"Inverted default authorization"**:
- **Closed by default**: Seats, datasets require explicit grants
- **Open by default**: Other resources accessible unless restricted

**Check flow**:
1. Check if resource type is "closed by default"
2. If closed, look for grant tuple
3. If open, look for restriction tuple
4. Apply inheritance (org → team → user)

### Frames Cache Integration

**Dual-read approach** for safe rollout:

```go
func (r *DualReader) Get(ctx context.Context, key string) (*Value, error) {
    // Try frames cache first
    val, err := r.framesRepo.Get(ctx, key)
    if err == nil {
        r.metrics.Increment("frames.hit")
        return val, nil
    }

    // Fallback to database
    r.metrics.Increment("frames.miss")
    return r.dbRepo.Get(ctx, key)
}
```

**Codec pattern** (`internal/frames/codec.go`):
- Serialize/deserialize keys and values
- Variable-length encoding for efficiency
- Protection against malicious frames

## Important Files

### Entry Points
- `cmd/main.go` - Application entry, service initialization

### Core Components
- `internal/datastore/` - Repository implementations
- `internal/http/` - HTTP handlers and routes
- `internal/grpc/` - gRPC service implementations
- `internal/authorization/authorizationcheck.go` - Authorization logic
- `internal/frames/` - Frames cache integration
- `internal/validation/` - Request validation

### Configuration
- `config/config.go` - Application configuration
- `deployments/` - Kubernetes manifests

## APIs

### gRPC API

**Authorization Service**:
- `IsAuthorized(principal, resource, relation)` - Single authorization check
- `BatchIsAuthorized([principals], [resources], [relations])` - Batch checks
- `GetRestrictionPolicy(id)` - Retrieve policy
- `ListRestrictionPolicies(filters)` - Query policies

### HTTP API

**Control Plane**:
- `POST /api/v1/restriction_policy` - Create policy
- `GET /api/v1/restriction_policy/:id` - Get policy
- `PUT /api/v1/restriction_policy/:id` - Update policy
- `DELETE /api/v1/restriction_policy/:id` - Delete policy
- `GET /api/v1/restriction_policy` - List policies (paginated)

**Datasets** (unstable):
- `POST /api/unstable/datasets` - Create dataset
- `GET /api/unstable/datasets/:id` - Get dataset
- `PUT /api/unstable/datasets/:id` - Update dataset
- `DELETE /api/unstable/datasets/:id` - Delete dataset
- `GET /api/unstable/datasets` - List datasets

**Dataset Config**:
- `POST /api/unstable/dataset_config` - Configure dataset access
- `GET /api/unstable/dataset_config/:product` - Get config by product

## Common Patterns

### Adding a New Handler

1. Define handler in `internal/http/handlers/`
2. Add route in `internal/http/router.go`
3. Implement validation in `internal/validation/`
4. Add metrics and tracing
5. Write tests in `*_test.go`

### Adding a New Repository

1. Define interface in `internal/datastore/`
2. Implement PostgreSQL version
3. Add Frames codec if needed
4. Implement dual-reader for migration
5. Add integration tests

### Error Handling

**50+ error codes** in `internal/validation/errors.go`:

```go
const (
    ErrInvalidInput = "INVALID_INPUT"
    ErrNotFound = "NOT_FOUND"
    ErrUnauthorized = "UNAUTHORIZED"
    ErrConflict = "CONFLICT"
    // ...
)
```

**Structured errors**:
```go
type ValidationError struct {
    Code    string
    Message string
    Field   string
}
```

### HTTP Response Format

**JSON:API style**:
```json
{
  "data": {
    "id": "123",
    "type": "restriction_policy",
    "attributes": {
      "name": "Policy Name",
      "description": "Description"
    }
  },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
```

### Testing Patterns

**Integration tests** (`*_integration_test.go`):
- Use test fixtures for data setup
- Test database with real PostgreSQL (via testcontainers)
- Mock external services
- Clean up after tests

**Example**:
```go
func TestCreatePolicy(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()

    repo := NewRepository(db)
    policy := &Policy{Name: "test"}

    err := repo.Create(context.Background(), policy)
    assert.NoError(t, err)
    assert.NotEmpty(t, policy.ID)
}
```

## Event Platform Integration

**Row-level security**:
- `accessible_indices` - List of indices user can access
- `restriction_filters` - Filters applied to queries

**Flow**:
1. User makes query request
2. Zoltron checks authorization
3. Returns accessible indices + filters
4. Event platform applies filters to query

## Performance Considerations

- **Cache warming**: Pre-populate Frames cache on startup
- **Batch operations**: Use `BatchIsAuthorized` for multiple checks
- **Connection pooling**: Database connection pool tuning
- **Query optimization**: Use indices, avoid N+1 queries
- **Monitoring**: Track P95/P99 latencies, error rates

## Deployment

**Kubernetes manifests** in `deployments/`:
- Control plane deployment
- Data plane deployment
- Provider service deployment
- Service definitions
- Network policies (CNP)

**Environment variables**:
- `DB_HOST`, `DB_PORT` - PostgreSQL connection
- `FRAMES_ENABLED` - Enable Frames cache integration
- `LOG_LEVEL` - Logging verbosity

## Key Confluence Docs

- [Context Platform Service Document](https://datadoghq.atlassian.net/wiki/spaces/FRAMES/pages/5147922742/Context+Platform+Service+Document)
- Search "Zoltron" in DataDog Confluence for additional docs
- Search "Granular Access" for access control patterns

## Common Tasks

### Adding a new resource type

1. Add enum to `internal/models/resource_type.go`
2. Update authorization logic
3. Add migration for enum
4. Update API handlers
5. Add tests
6. Update documentation

### Modifying authorization logic

1. Read existing logic in `internal/authorization/`
2. Write tests for new behavior first
3. Update `IsAuthorized` implementation
4. Run integration tests
5. Update metrics/traces
6. Deploy with feature flag

### Frames cache integration

1. Define proto in `internal/frames/proto/`
2. Implement codec in `internal/frames/codec.go`
3. Create dual-reader wrapper
4. Add metrics for cache hit/miss
5. Test with Frames disabled (DB only)
6. Enable shadow mode
7. Monitor and validate
8. Switch to enforcement mode
