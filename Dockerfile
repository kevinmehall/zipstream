FROM rust:1.36.0@sha256:c52a5038fe5da4ee5d454b2294a297659ccabbf4419894b5bc91d2cd7817b367 as build

# Build and cache dependencies
RUN apt-get update && apt-get install unzip

WORKDIR /crate
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src/ && \
    echo 'fn main(){}' > src/main.rs && \
    cargo build --release && \
    rm -f target/release/deps/zipstream* target/release/zipstream

# Build actual source
COPY src ./src
RUN cargo build --release

# Run tests
FROM build as test
RUN cargo test --release

# Deployment image
FROM ubuntu:bionic@sha256:c303f19cfe9ee92badbbbd7567bc1ca47789f79303ddcef56f77687d4744cd7a
RUN apt-get update && apt-get install -y libssl1.1 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /crate/target/release/zipstream /usr/local/bin/
CMD ["zipstream"]
EXPOSE 3000
