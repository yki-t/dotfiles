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
- not define free functions. All functions must be associated with a type via `impl` blocks (exceptions: `main`, utility modules, `#[test]`, macro-attributed functions like `#[function_component]`/`#[hook]`).

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
├── constants/         # constants and env vars
├── extractors/        # custom extractors (typed request extraction, e.g. AuthUser, Json validation)
├── middlewares/       # middleware
├── handlers/          # request handlers
├── services/          # business logic
├── models/            # data structures and DB queries
│   └── {resource}/    # resource-specific modules
└── utils/             # utility functions
```

### Layer Responsibilities

| Layer   | Responsibility |
|---------|----------------|
| Handler | Transaction management, authentication/authorization, response formation |
| Service | Business logic, validation |
| Model   | Type definitions, DB queries |

---

## Frontend (Yew/WASM)

### Directory Structure

```
src/
├── main.rs
├── auth/            # Authentication logic
├── error/           # Error types and messages
├── components/      # Reusable UI components
│   └── common/      # Common components (Button, Loading, etc.)
├── pages/           # Page components
├── contexts/        # Global state management (Reducer pattern)
├── hooks/           # Custom hooks
├── guards/          # Route guards
├── services/        # External service integration
│   └── api_client/  # API client (submodules per resource)
├── styles/          # SCSS styles
└── utils/           # Utility functions
```

### Design Patterns

| Pattern | Description |
|---------|-------------|
| Component | `#[function_component]` + `Properties` |
| State Management | Context + Reducer (`use_reducer` + `ContextProvider`) |
| API Client | Common request method + resource-specific submodules |
| Hook | Custom hooks with `#[hook]` attribute |
