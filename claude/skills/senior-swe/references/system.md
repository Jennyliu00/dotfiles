# Systems & Infrastructure Knowledge for Senior Engineers

## Distributed Systems Fundamentals

### CAP Theorem

**Trade-offs between**:
- **Consistency**: All nodes see the same data at the same time
- **Availability**: Every request receives a response
- **Partition Tolerance**: System continues despite network partitions

**In practice**:
- **CP Systems**: Prioritize consistency (e.g., Zookeeper, etcd, HBase)
- **AP Systems**: Prioritize availability (e.g., Cassandra, DynamoDB, Riak)
- **CA Systems**: Rare in distributed environments (single-node databases)

**Real-world implications**:
```
Network partition occurs:
├── CP: Reject writes to maintain consistency
└── AP: Accept writes, resolve conflicts later
```

### Consistency Models

**Strong Consistency**:
- Read always returns most recent write
- Requires coordination (slower, lower availability)
- Use when: Financial transactions, inventory management

**Eventual Consistency**:
- Reads may return stale data temporarily
- All replicas converge eventually
- Use when: Social media feeds, caches, read-heavy workloads

**Causal Consistency**:
- Preserves causally-related operations order
- More relaxed than strong, stricter than eventual
- Use when: Chat systems, collaborative editing

### Scalability Patterns

**Vertical Scaling**:
- Add more CPU/RAM to single machine
- Limits: Hardware ceiling, cost, single point of failure
- Use when: Simple, initial growth phase

**Horizontal Scaling**:
- Add more machines
- Requires: Load balancing, stateless services, data partitioning
- Use when: Need unlimited scale, fault tolerance

**Data Partitioning**:

**Horizontal (Sharding)**:
```
Users table:
├── Shard 1: user_id % 3 == 0
├── Shard 2: user_id % 3 == 1
└── Shard 3: user_id % 3 == 2
```

**Vertical (by feature)**:
```
Database:
├── Users DB: user profiles
├── Orders DB: order data
└── Analytics DB: metrics and logs
```

**Replication Strategies**:

**Leader-Follower**:
```
Leader (writes) → Replicas (reads)
```
- Pros: Read scaling, simple
- Cons: Leader bottleneck, replication lag

**Multi-Leader**:
```
Leader A ↔ Leader B
```
- Pros: Write scaling, geographic distribution
- Cons: Conflict resolution complexity

**Leaderless (Quorum)**:
```
Client → Write to N nodes
         Wait for W acknowledgments
         Read from R nodes
         W + R > N ensures consistency
```

## Performance & Optimization

### Latency Numbers Every Engineer Should Know

```
L1 cache reference               0.5 ns
Branch mispredict                5   ns
L2 cache reference               7   ns
Mutex lock/unlock               25   ns
Main memory reference          100   ns
Compress 1KB with Snappy     3,000   ns (3 μs)
Send 1KB over 1 Gbps network 10,000  ns (10 μs)
SSD random read            150,000   ns (150 μs)
Read 1MB sequentially      250,000   ns (250 μs)
Round trip in datacenter   500,000   ns (500 μs)
Disk seek               10,000,000   ns (10 ms)
Read 1MB from network   10,000,000   ns (10 ms)
Read 1MB from disk      30,000,000   ns (30 ms)
Send packet CA→EU      150,000,000   ns (150 ms)
```

**Key insights**:
- Memory is 100x faster than SSD, 300x faster than disk
- Network within datacenter is fast (~0.5ms)
- Cross-region network is slow (150ms+)
- Disk seeks are expensive, sequential reads are better

### Caching Strategies

**Cache-Aside (Lazy Loading)**:
```go
func Get(key string) (Value, error) {
    // 1. Try cache
    val, err := cache.Get(key)
    if err == nil {
        return val, nil
    }

    // 2. Cache miss - load from DB
    val, err = db.Get(key)
    if err != nil {
        return nil, err
    }

    // 3. Populate cache
    cache.Set(key, val, ttl)
    return val, nil
}
```

**Write-Through**:
```go
func Set(key string, val Value) error {
    // 1. Write to cache
    cache.Set(key, val, ttl)

    // 2. Write to DB
    return db.Set(key, val)
}
```

**Write-Behind (Async)**:
```go
func Set(key string, val Value) error {
    // 1. Write to cache (fast)
    cache.Set(key, val, ttl)

    // 2. Queue DB write (async)
    queue.Enqueue(WriteJob{key, val})
    return nil
}
```

**Cache Invalidation Strategies**:
- **TTL (Time To Live)**: Expire after fixed duration
- **Event-based**: Invalidate on writes
- **LRU (Least Recently Used)**: Evict old entries
- **Write-through + TTL**: Combine for best results

### Load Balancing

**Algorithms**:
- **Round Robin**: Distribute evenly
- **Least Connections**: Send to least busy server
- **IP Hash**: Consistent routing per client
- **Weighted**: Adjust for different capacities

**Health Checks**:
```yaml
health_check:
  path: /health
  interval: 10s
  timeout: 2s
  unhealthy_threshold: 3
  healthy_threshold: 2
```

### Circuit Breaker Pattern

```go
type CircuitBreaker struct {
    state        State  // Closed, Open, HalfOpen
    failureCount int
    threshold    int
    timeout      time.Duration
}

func (cb *CircuitBreaker) Call(fn func() error) error {
    switch cb.state {
    case Open:
        if time.Since(cb.lastFailure) > cb.timeout {
            cb.state = HalfOpen
        } else {
            return ErrCircuitOpen
        }
    }

    err := fn()
    if err != nil {
        cb.failureCount++
        if cb.failureCount > cb.threshold {
            cb.state = Open
        }
        return err
    }

    cb.state = Closed
    cb.failureCount = 0
    return nil
}
```

**Use when**: Calling external services, databases, APIs that can fail

## Database Systems

### ACID Properties

- **Atomicity**: All or nothing (transactions)
- **Consistency**: Data validity constraints maintained
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed data persists

### Isolation Levels

**Read Uncommitted**:
- Dirty reads possible
- Fastest, least safe

**Read Committed** (PostgreSQL default):
- No dirty reads
- Non-repeatable reads possible

**Repeatable Read**:
- Consistent reads within transaction
- Phantom reads possible

**Serializable**:
- Full isolation
- Slowest, safest

### Indexing

**Types**:
- **B-Tree**: Default, good for range queries
- **Hash**: Fast equality checks, no range queries
- **GiST/GIN**: Full-text search, geometric data
- **BRIN**: Block range index for large, sorted tables

**Index guidelines**:
- ✅ Index foreign keys
- ✅ Index WHERE clause columns
- ✅ Index ORDER BY columns
- ❌ Don't over-index (slows writes)
- ❌ Don't index low-cardinality columns (e.g., boolean)

**Composite indexes**:
```sql
-- ✅ Good for: WHERE user_id = ? AND created_at > ?
CREATE INDEX idx_user_created ON orders(user_id, created_at);

-- ❌ Bad order: created_at is more selective
CREATE INDEX idx_created_user ON orders(created_at, user_id);
```

### Query Optimization

**Use EXPLAIN ANALYZE**:
```sql
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE user_id = 123 AND status = 'pending';
```

**Look for**:
- Seq Scan (bad for large tables)
- Index Scan (good)
- Nested Loop (can be expensive)
- Hash Join (good for large sets)

**N+1 Query Problem**:
```go
// ❌ Bad - N+1 queries
users := getUsers()
for _, user := range users {
    orders := getOrders(user.ID)  // N queries
}

// ✅ Good - 2 queries
users := getUsers()
userIDs := extractIDs(users)
orders := getOrdersByUserIDs(userIDs)  // 1 query with IN clause
```

### Connection Pooling

```go
db, err := sql.Open("postgres", dsn)
db.SetMaxOpenConns(25)           // Max connections
db.SetMaxIdleConns(5)            // Idle connections to keep
db.SetConnMaxLifetime(5*time.Minute)  // Recycle connections
```

**Guidelines**:
- Start with `MaxOpenConns = num_cores * 2`
- Monitor connection usage
- Set `ConnMaxLifetime` to avoid stale connections
- Use prepared statements for repeated queries

## Observability

### The Three Pillars

**Metrics** (What's happening?):
```go
// Counter: Monotonically increasing
requestCounter.Inc()

// Gauge: Current value
activeConnections.Set(25)

// Histogram: Distribution of values
responseTime.Observe(duration)
```

**Logs** (What happened?):
```go
log.WithFields(log.Fields{
    "user_id": userID,
    "action": "login",
    "ip": req.RemoteAddr,
}).Info("User logged in")
```

**Traces** (Where did time go?):
```go
span := trace.StartSpan(ctx, "database.query")
defer span.End()

span.SetAttributes(
    attribute.String("query", query),
    attribute.Int("rows", len(results)),
)
```

### Key Metrics to Track

**Service Health**:
- Request rate (requests/sec)
- Error rate (errors/sec, %)
- Latency (P50, P95, P99, P999)

**Resource Utilization**:
- CPU usage (%)
- Memory usage (%)
- Disk I/O (IOPS, throughput)
- Network I/O (bandwidth)

**Database**:
- Query latency
- Connection pool usage
- Slow query count
- Replication lag

**Application**:
- Active goroutines
- GC pause time
- Heap allocation
- Cache hit rate

### SLIs, SLOs, SLAs

**SLI (Service Level Indicator)**:
- Measurable metric (e.g., request success rate)

**SLO (Service Level Objective)**:
- Target for SLI (e.g., 99.9% success rate)

**SLA (Service Level Agreement)**:
- Contractual commitment with consequences

**Error Budget**:
```
If SLO = 99.9% uptime:
├── Allowed downtime: 43 minutes/month
├── If exceeded: Freeze feature work, focus on reliability
└── If under: Continue feature development
```

## Infrastructure as Code

### Container Best Practices

**Dockerfile**:
```dockerfile
# ✅ Use specific tags, not "latest"
FROM golang:1.21-alpine

# ✅ Multi-stage builds for smaller images
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o /app/server

FROM alpine:latest
COPY --from=builder /app/server /server
ENTRYPOINT ["/server"]

# ✅ Run as non-root user
USER nobody

# ✅ Use .dockerignore
# .git, *.md, test files
```

### Kubernetes Patterns

**Resource Limits**:
```yaml
resources:
  requests:
    cpu: 100m      # Guaranteed
    memory: 128Mi
  limits:
    cpu: 200m      # Maximum
    memory: 256Mi
```

**Health Checks**:
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
```

**Horizontal Pod Autoscaler**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Security

### Authentication vs Authorization

**Authentication**: Who are you?
- Username/password
- OAuth/OIDC
- API keys
- Certificates

**Authorization**: What can you do?
- Role-Based Access Control (RBAC)
- Attribute-Based Access Control (ABAC)
- Relation-based (Zanzibar model)

### Security Best Practices

**Defense in Depth**:
```
┌─────────────────────────────────┐
│ WAF / DDoS Protection           │
├─────────────────────────────────┤
│ Load Balancer / SSL Termination │
├─────────────────────────────────┤
│ API Gateway / Rate Limiting     │
├─────────────────────────────────┤
│ Application (Input Validation)  │
├─────────────────────────────────┤
│ Database (Parameterized Queries)│
└─────────────────────────────────┘
```

**Principle of Least Privilege**:
- Give minimum permissions needed
- Regularly audit and revoke unused permissions
- Use temporary credentials when possible

**Secrets Management**:
- Never commit secrets to git
- Use secret management tools (Vault, AWS Secrets Manager)
- Rotate secrets regularly
- Use environment variables or mounted volumes

## Additional Resources

- [Designing Data-Intensive Applications (Martin Kleppmann)](https://dataintensive.net/)
- [Site Reliability Engineering (Google)](https://sre.google/books/)
- [System Design Primer](https://github.com/donnemartin/system-design-primer)
- [High Scalability Blog](http://highscalability.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
