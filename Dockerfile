FROM rust:1.36.0@sha256:c52a5038fe5da4ee5d454b2294a297659ccabbf4419894b5bc91d2cd7817b367 as build

# Build and cache dependencies
RUN apt-get update && apt-get install unzip
RUN mkdir -p /crate/src/ && echo 'fn main(){}' > /crate/src/main.rs
WORKDIR /crate
COPY Cargo.toml .
COPY Cargo.lock .
RUN cargo build --release

# Build actual source
COPY src/* /crate/src/
RUN touch /crate/src/main.rs && cargo build --release

# Deployment image
FROM ubuntu:bionic@sha256:c303f19cfe9ee92badbbbd7567bc1ca47789f79303ddcef56f77687d4744cd7a
RUN apt-get update && apt-get install -y libssl1.1 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /crate/target/release/zipstream /usr/local/bin/
CMD ["zipstream"]
EXPOSE 3000
