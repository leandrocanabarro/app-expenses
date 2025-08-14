#!/bin/bash

# Development setup script for App Expenses

set -e

echo "🚀 App Expenses - Development Setup"
echo "====================================="

# Check if Docker is available
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo "✅ Docker and Docker Compose found"
    echo ""
    echo "🐳 Docker options:"
    echo "  1. Run application: docker-compose up app"
    echo "  2. Development mode: docker-compose run --rm dev"
    echo "  3. Build only: docker-compose build"
    echo ""
fi

# Check if Flutter is available
if command -v flutter &> /dev/null; then
    echo "✅ Flutter found"
    flutter --version
    echo ""
    echo "💻 Local development:"
    echo "  1. Install dependencies: flutter pub get"
    echo "  2. Run web: flutter run -d chrome"
    echo "  3. Run tests: flutter test"
    echo ""
else
    echo "❌ Flutter not found in PATH"
    echo ""
    echo "📋 Setup options:"
    echo "  1. Use GitHub Codespaces (recommended)"
    echo "  2. Use Docker: docker-compose up app"
    echo "  3. Install Flutter locally: https://flutter.dev/docs/get-started/install"
    echo ""
fi

echo "📚 Documentation:"
echo "  - README.md for detailed setup instructions"
echo "  - Docker configuration in docker-compose.yml"
echo "  - Codespaces configuration in .devcontainer/"
echo ""

echo "🌟 Quick start with Docker:"
echo "  docker-compose up app"
echo ""
echo "🌐 Access the app at: http://localhost:3000"