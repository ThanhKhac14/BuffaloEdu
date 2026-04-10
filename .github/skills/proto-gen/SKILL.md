# SKILL: Protobuf & gRPC Generation

Auto-activates when: editing `.proto` files, running `buf generate`, setting up gRPC communication

---

## Directory layout

```
proto/
├── buf.yaml              ← lint + breaking change rules
├── buf.gen.yaml          ← generation config
└── {service}/
    └── v1/
        └── {service}.proto
```

## buf.yaml

```yaml
version: v2
lint:
  use:
    - DEFAULT
  except:
    - PACKAGE_VERSION_SUFFIX
breaking:
  use:
    - FILE
```

## buf.gen.yaml

```yaml
version: v2
plugins:
  - plugin: buf.build/protocolbuffers/go
    out: ../services
    opt:
      - paths=source_relative
  - plugin: buf.build/grpc/go
    out: ../services
    opt:
      - paths=source_relative
      - require_unimplemented_servers=false
```

## Proto file template

```protobuf
syntax = "proto3";

package buffaloedu.{service}.v1;

option go_package = "github.com/buffaloedu/services/{service}/gen/{service}v1";

import "google/protobuf/timestamp.proto";

// Every service MUST have healthz
service {Service}Service {
  rpc Healthz(HealthzRequest) returns (HealthzResponse);
  rpc Create{Entity}(Create{Entity}Request) returns (Create{Entity}Response);
  rpc Get{Entity}(Get{Entity}Request) returns (Get{Entity}Response);
  rpc Update{Entity}(Update{Entity}Request) returns (Update{Entity}Response);
  rpc Delete{Entity}(Delete{Entity}Request) returns (Delete{Entity}Response);
  rpc List{Entity}s(List{Entity}sRequest) returns (List{Entity}sResponse);
}

message HealthzRequest {}
message HealthzResponse { string status = 1; }

message {Entity} {
  string id         = 1;
  string created_at = 2;  // ISO 8601 string
  string updated_at = 3;
  // domain fields...
}

message Create{Entity}Request {
  // required fields only, no id/timestamps
}
message Create{Entity}Response { {Entity} {entity} = 1; }

message Get{Entity}Request    { string id = 1; }
message Get{Entity}Response   { {Entity} {entity} = 1; }

message Update{Entity}Request { string id = 1; /* updatable fields */ }
message Update{Entity}Response { {Entity} {entity} = 1; }

message Delete{Entity}Request  { string id = 1; }
message Delete{Entity}Response { bool success = 1; }

message List{Entity}sRequest  { int32 page = 1; int32 page_size = 2; }
message List{Entity}sResponse { repeated {Entity} items = 1; int32 total = 2; }
```

## go.mod replace directive (each service)

```go
// services/{service}/go.mod
module github.com/buffaloedu/services/{service}

go 1.22

require (
    google.golang.org/grpc v1.62.0
    google.golang.org/protobuf v1.33.0
    github.com/buffaloedu/proto v0.0.0
)

replace github.com/buffaloedu/proto => ../../proto
```

## Generation workflow

```bash
# From /proto directory
buf lint                  # validate .proto files
buf generate              # generate Go stubs → /services/{name}/gen/
buf breaking --against '.git#branch=main'  # check no breaking changes
```

## After adding a new RPC
1. Add to `.proto` file
2. Run `buf generate`
3. Implement in `handler/{service}_handler.go`
4. Add business logic in `service/{service}_service.go`
5. Add SQL in `repository/{service}_repository.go` (if DB needed)
6. Register in gateway routing (`services/gateway/internal/handler/`)

## Common mistakes
- ❌ `require_unimplemented_servers=true` — breaks when adding new RPCs
- ❌ Importing proto types directly in service/repository layers — use model types
- ❌ Forgetting `healthz` RPC
- ❌ Using `string` for timestamps (use ISO 8601 string or google.protobuf.Timestamp)
- ❌ Shared proto fields across services — each service owns its own messages
