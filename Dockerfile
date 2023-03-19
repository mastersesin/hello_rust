FROM rust:1.68

COPY . .

RUN apt update

RUN apt install fuse libfuse-dev pkg-config

RUN cargo build --release
#
CMD ["./target/release/hello_world_rust"]
