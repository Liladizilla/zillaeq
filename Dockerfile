FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

# Pre-download dependencies
RUN flutter config --no-analytics && flutter precache

WORKDIR /app

# Copy project
COPY . .

# Build
CMD ["flutter", "build", "apk", "--release", "--split-per-abi"]
