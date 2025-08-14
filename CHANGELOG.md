# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-08-14

### Added
- Initial release of App Expenses
- Clean Architecture implementation with domain/data/presentation layers
- SQLite local database with expense and category management
- Voice command functionality in Portuguese (pt-BR)
- Material Design 3 UI with light/dark theme support
- Navigation with GoRouter
- State management with Riverpod
- Form validation and error handling
- Basic expense and category CRUD operations
- Voice commands for creating categories and adding expenses
- Date and category filtering for expenses
- Currency formatting for Brazilian Real (R$)
- Comprehensive test suite (unit, widget, integration)
- CI/CD pipeline with GitHub Actions
- Complete documentation and setup instructions

### Voice Commands Supported
- "criar categoria {nome}" - Create new category
- "nova categoria {nome}" - Create new category (alternative)
- "adicionar gasto {valor} {descrição}" - Add expense
- "gastei {valor} em {descrição}" - Add expense (alternative)
- "lançar gasto {valor} {descrição}" - Add expense (alternative)
- Support for category specification: "na categoria {nome}"
- Support for currency formats: R$, comma decimal separators

### Technical Features
- Clean Architecture with separation of concerns
- Repository pattern for data access
- Use cases for business logic
- Dependency injection with Riverpod
- SQLite database with migrations
- Voice-to-text integration
- Comprehensive error handling
- Material Design 3 components
- Responsive design principles
- Code formatting and analysis with flutter_lints

### Future Planned Features
- Charts and reports with fl_chart
- Advanced filtering options  
- Data export functionality
- Cloud backup and synchronization
- Budget and goal tracking
- Multi-account support