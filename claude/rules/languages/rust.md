---
paths:*.rs
---

# Rust Rules

## Version

Edition: 2024

Always use the latest version from:
https://blog.rust-lang.org/releases/latest/

Example: 1.93.0 (as of writing)

## Basic Policies

You must:
- use `-D warnings` to treat all warnings as errors.
- use docker-compose.yml, prevent using `cargo` directly.
- use `stable` toolchain, prevent using `nightly` toolchains.
- not use `allow(dead_code)`, `unwrap`, or `expect` in your code.
- use captured identifiers in format strings, e.g. `format!("value: {value}")`.
- not leave unused code or commented-out code.
- not define free functions. All functions must be associated with a type via `impl` blocks (exceptions: `main`, utility modules, `#[test]`, macro-attributed functions like `#[component]`/`#[server(...)]`).

You should use the latest versions of dependencies with `"*"` in `Cargo.toml`.

## Error Handling

You must:
- define custom error type like `Error` using `anyhow` crate (prevent using `thiserror` or `thiserror`-like crates).
- define `crate::error::Error` and export it
- define `pub type Result<T> = std::result::Result<T, crate::error::Error>;`
- implement `From<T>` for `crate::error::Error` for each error type `T` you use in your code.
- use `crate::Result<T>` in your functions

---

## API Server (Axum)

### Directory Structure

```
src/
├── main.rs            # entry point
├── error.rs           # custom error type
├── state.rs           # AppState (DB pool, clients, connections)
├── routes.rs          # route definitions
├── constants/         # constants and env vars
├── extractors/        # custom extractors (e.g. AuthUser, RequireAuth)
├── middlewares/       # middleware (e.g. JWT verification)
├── handlers/          # request handlers
├── services/          # business logic
├── repositories/      # data access layer (trait + Postgres/Mock implementations)
├── models/            # data structures and request/response types
│   └── {resource}/    # resource-specific modules
└── utils.rs            # utility functions
```

### Layer Responsibilities

| Layer      | Responsibility |
|------------|----------------|
| Handler    | Transaction management, authentication/authorization, response formation |
| Service    | Business logic, validation |
| Repository | Database abstraction (trait-based with Postgres/Mock implementations) |
| Model      | Type definitions, request/response types |

---

## Frontend (Leptos SSR + Hydration)

### Directory Structure

```
src/
├── app.rs             # router configuration
├── auth/              # authentication logic (Cognito, JWT)
├── error/             # error types with codes and messages
├── constants/         # constants and env vars
├── components/        # reusable UI components
│   ├── common/        # common components (Button, Loading, etc.)
│   ├── layout/        # layout components (Header, Footer)
│   ├── modals/        # modal components
├── pages/             # page components
├── contexts/          # global state management (Context + Signal)
├── hooks/             # custom hooks
├── guards/            # route guards
├── server_fn/         # Leptos server functions (SSR-only API calls)
├── services/          # client-side services (WebSocket, WebRTC)
└── utils/             # utility functions
```

### Design Patterns

| Pattern | Description |
|---------|-------------|
| Component | `#[component]` + `#[prop(...)]` attributes |
| State Management | `provide_context()` / `expect_context()` + `RwSignal<T>` |
| Server Function | `#[server(Name, "/api")]` for SSR-only API calls |
| Hook | Plain functions returning structs with reactive signals |
