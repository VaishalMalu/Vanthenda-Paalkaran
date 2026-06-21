# Vanthenda Paalkaran

## Overview

Vanthenda Paalkaran is a premium subscription delivery management platform built for dairy vendors and subscription-based businesses. It digitizes traditional paper-based milk cards and delivers an offline-capable business workflow for customer management, delivery operations, billing, payments, analytics, and staff coordination.

## Value Proposition

This application is designed for independent vendors, distributors, and field staff who need a reliable system to manage daily recurring deliveries with minimal disruption. It replaces manual recording, reduces reconciliation errors, improves customer transparency, and provides the operational intelligence required for scalable growth.

## Product Scope

- Digital milk card management for morning, evening, and extra deliveries.
- Customer creation, address management, and subscription scheduling.
- Automatic monthly billing, invoice generation, and PDF export.
- Online payment support and collection tracking.
- Vacation mode and emergency request handling.
- Offline-first operation with background synchronization.
- Business analytics and delivery reporting.

## Architecture

Vanthenda Paalkaran follows a feature-first, clean architecture model that separates concerns and supports long-term maintainability.

### Architectural principles

- Feature-first module organization for high cohesion and low coupling.
- Clean architecture boundaries between presentation, domain, and data layers.
- Repository pattern for abstracting data sources.
- Dependency injection for service composition and testability.
- SOLID design principles to improve extensibility and stability.
- Offline-first user experience with local persistence and sync reconciliation.

### Core layers

- `lib/core`: Shared infrastructure, theme, routing, storage, and services.
- `lib/features`: Domain features organized by business capability.
- `lib/features/<feature>/data`: Data sources, models, repositories.
- `lib/features/<feature>/presentation`: UI, providers, screens, and widgets.
- `lib/features/<feature>/domain`: Business rules, use cases, and services.

## Repository Structure

Maintain a clean repository structure to support fast onboarding and scalable development. The following structure is the target for this project:

- `/android` - Android platform configuration and native resources.
- `/ios` - iOS platform configuration and native resources.
- `/linux` - Linux desktop support and CMake configuration.
- `/macos` - macOS desktop support.
- `/windows` - Windows desktop support.
- `/web` - Web deployment assets and configuration.
- `/lib` - Dart application source code.
- `/assets` - Static assets such as images and fonts.
- `/test` - Unit, widget, and integration tests.
- `pubspec.yaml` - Dart package and dependency manifest.
- `.gitignore` - Git ignore rules.
- `README.md` - Project documentation.
- `supabase_schema.sql` and other migration scripts.

## Repository Maintenance Guidelines

- Keep secrets out of source control: use `.env` and ignore all private key files.
- Commit only application code, configuration templates, and necessary metadata.
- Use descriptive commit messages and avoid large unrelated changes in a single commit.
- Keep generated files and build artifacts excluded via `.gitignore`.
- Keep the repository organized by feature and avoid mixing unrelated concerns in the same directory.

## Technology Stack

### Frontend
- Flutter
- Riverpod
- GoRouter
- Material 3

### Backend
- Supabase
- PostgreSQL
- Supabase Authentication
- Supabase Storage
- Realtime sync

### Local Persistence
- Hive
- Shared Preferences

### Notifications and Analytics
- Firebase Cloud Messaging
- Firebase Analytics
- Firebase Crashlytics

### Payments
- Razorpay
- UPI

### PDF and Documents
- `pdf` package
- `printing` package

### Maps
- Google Maps API

## Deployment Targets

- Android
- iOS
- Web
- Desktop (Windows, macOS, Linux)

## Setup and Development

### Prerequisites

- Flutter SDK installed and configured
- Dart SDK compatible with Flutter version
- Supabase project and credentials
- Firebase project for notifications and analytics

### Setup steps

1. Clone the repository.
2. Create a local `.env` file with environment-specific credentials.
3. Run `flutter pub get`.
4. Run code generation if required:
   - `dart run build_runner build --delete-conflicting-outputs`
5. Run the app with `flutter run` or use a supported device target.

## Environment and Secrets

- Do not commit `.env` files or any secret key files.
- Use `.gitignore` for all local configuration and private credential files.
- Provide configuration templates if needed, but keep actual secrets local.

## Quality and Stability

- Prioritize maintainable code and consistent architecture.
- Keep UI and business logic separated.
- Prefer incremental improvements over large structural rewrites.
- Validate critical paths with tests before merging.

## Recommended Repository Practices

- Maintain a stable `main` branch for releases.
- Use feature branches for new work.
- Review pull requests for architecture alignment and code quality.
- Keep merge commits small and focused.
- Document major architectural decisions in the repository.

## Project Goal

Deliver an enterprise-grade subscription delivery platform that modernizes traditional workflows, supports offline operation, and provides a scalable foundation for future service expansion.
