#!/bin/bash

# Setup script for Flutter development environment in Codespaces

set -e

echo "Setting up Flutter development environment..."

# Update package list
sudo apt-get update

# Install required dependencies
sudo apt-get install -y \
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
    python3

# Install Flutter
FLUTTER_VERSION="3.24.5"
FLUTTER_HOME="/flutter"

echo "Installing Flutter ${FLUTTER_VERSION}..."
sudo wget -O /tmp/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
sudo tar xf /tmp/flutter.tar.xz -C /
sudo rm /tmp/flutter.tar.xz
sudo chown -R vscode:vscode ${FLUTTER_HOME}

# Add Flutter to PATH
echo 'export PATH="/flutter/bin:$PATH"' >> ~/.bashrc
export PATH="/flutter/bin:$PATH"

# Configure Flutter
flutter config --no-analytics
flutter precache --web

# Verify installation
echo "Flutter installation complete!"
flutter doctor -v

echo "Setup completed successfully!"