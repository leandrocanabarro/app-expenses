# Use official Ubuntu image as base
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install Flutter
ENV FLUTTER_VERSION=3.24.5
ENV FLUTTER_HOME=/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && tar xf flutter.tar.xz \
    && rm flutter.tar.xz \
    && mv flutter ${FLUTTER_HOME}

# Configure Flutter
RUN flutter config --no-analytics \
    && flutter precache \
    && flutter doctor

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Expose port for web development
EXPOSE 3000

# Default command
CMD ["flutter", "run", "-d", "web-server", "--web-port", "3000", "--web-hostname", "0.0.0.0"]