# Cache Layer
FROM lukemathwalker/cargo-chef:latest-rust-1.68.0 AS chef
WORKDIR app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
RUN apt update
RUN apt -y install fuse libfuse-dev pkg-config
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .
RUN cargo build --release --bin hello_world_rust

# Main Build Layer
FROM debian:bullseye-slim AS runtime
RUN apt update
RUN apt -y install fuse libfuse-dev pkg-config
WORKDIR app
RUN mkdir /app/test
COPY --from=builder /app/target/release/hello_world_rust /usr/local/bin

ENTRYPOINT ["/usr/local/bin/hello_world_rust"]
