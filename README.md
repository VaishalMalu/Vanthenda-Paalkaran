# Vanthenda Paalkaran

## Overview

Vanthenda Paalkaran is a production-grade, offline-first dairy subscription management platform designed to replace traditional handwritten milk cards with a modern digital ecosystem.

The application supports independent milk vendors, dairy distributors, and subscription delivery businesses by providing customer management, delivery tracking, billing, payment processing, analytics, and business automation in a single integrated solution.

## Vision

To become the operating system for subscription delivery businesses by digitizing and automating recurring daily deliveries.

Initial focus:
- Milk delivery

Future expansion:
- Water can delivery
- Newspaper delivery
- Grocery subscription
- Tiffin services
- Laundry pickup
- Gas cylinder distribution

## Problem Statement

Most local milk vendors still depend on handwritten milk cards and notebooks to record daily deliveries, which leads to operational challenges such as:

- Manual entry errors
- Lost customer records
- Inaccurate monthly calculations
- Payment disputes
- No delivery history
- No analytics or business insights
- Lack of digital transparency

Vanthenda Paalkaran transforms these processes into a reliable and scalable digital solution.

## Core Objectives

- Replace traditional paper milk cards
- Simplify customer management
- Automate monthly billing
- Enable offline operations
- Improve payment collection
- Provide business analytics
- Increase transparency between vendors and customers

## Target Users

### Vendors
- Independent milk vendors
- Local dairy suppliers
- Subscription delivery businesses
- Milk distributors

### Customers
- Residential customers
- Apartment associations
- Commercial customers
- Subscription consumers

### Staff
- Delivery executives
- Collection staff
- Business managers

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

### Local Storage
- Hive
- Shared Preferences

### Notifications
- Firebase Cloud Messaging
- Firebase Analytics
- Firebase Crashlytics

### Payments
- Razorpay
- UPI

### PDF
- pdf
- printing

### Maps
- Google Maps API

## Architecture

Vanthenda Paalkaran is implemented with a feature-first architecture and clean design principles to support maintainability and scalability.

Key architectural characteristics:

- Feature-first module organization
- Clean architecture boundaries
- Repository pattern for data access
- SOLID design principles
- Dependency injection for decoupled services
- Modular design for incremental growth

## User Roles

### Vendor
- Business management
- Customer management
- Delivery management
- Billing
- Payments
- Analytics
- Reports

### Customer
- Milk card tracking
- Delivery history
- Bill records
- Payment history
- Vacation requests
- Emergency requests
- Profile management

### Staff
- Delivery route management
- Customer list management
- Delivery status updates
- Task tracking

## Core Modules

### Authentication
- Secure login
- Session management
- Role-based navigation
- Persistent authentication

### Vendor Management
- Business profile management
- Logo upload
- Business settings
- Invoice branding
- Payment configuration

### Customer Management
- Add, edit, delete customers
- Search and group customers
- Address and contact management

### Milk Types
- Cow milk
- Buffalo milk
- A2 milk
- Organic milk
- Custom milk products
- Dynamic pricing

### Digital Milk Card
- Morning and evening delivery tracking
- Extra delivery support
- Monthly calendar view
- Historical delivery records

### Delivery Management
- Single and bulk delivery updates
- Skip delivery
- Pause delivery
- Delivery history

### Billing
- Automated monthly billing
- Invoice generation
- PDF export
- Bill sharing
- Outstanding balance tracking

### Payments
- Payment tracking
- Collection reporting
- Payment history
- Online payment processing

### Vacation Management
- Pause and resume service
- Date-based delivery suspension
- Automatic vacation handling

### Emergency Requests
- Extra milk requests
- Urgent delivery support
- Vendor notification workflows
- Status tracking

### Notifications
- Bill reminders
- Delivery notifications
- Payment reminders
- Emergency alerts

### Analytics
- Daily revenue reports
- Monthly revenue reports
- Milk sales tracking
- Top customer identification
- Pending payment monitoring
- Growth analytics

### Offline Mode
- Offline customer creation
- Offline delivery entry
- Offline billing
- Background synchronization
- Conflict resolution

## Design Principles

- Minimal and professional design
- Human-centered experience
- Premium visual quality
- Responsive and accessible layouts
- Offline-first behavior
- Mobile-first interaction
- Tamil-first localization support
- Tablet and desktop compatibility

## UI Standards

- Material 3 design system
- Light theme support
- Professional typography
- Consistent spacing
- Large touch targets
- Smooth animations
- Responsive layouts
- No unnecessary visual clutter

## Security

- Supabase Authentication
- Row Level Security
- Input validation
- Secure local storage
- Session management
- Protected API access
- Role-based authorization

## Database Model

Primary tables:
- vendors
- customers
- milk_types
- deliveries
- payments
- vacation_requests
- emergency_requests
- notifications
- vendor_settings
- audit_logs
- invoice_templates
- analytics_snapshots

## Storage Buckets

- vendor-logos
- invoices
- customer-files

## Performance Goals

- Application startup under 2 seconds
- Smooth 60 FPS animations
- Reliable offline functionality
- Fast synchronization
- Optimized API calls
- Efficient database queries
- Low battery consumption
- Low memory usage

## Testing

- Unit testing
- Widget testing
- Integration testing
- Offline testing
- Performance testing
- Security testing
- Edge case testing

## Scalability

Built to support:
- Single vendors
- Multi-location businesses
- Large dairy operations
- Enterprise deployments
- Multi-city expansion
- White-label distribution

## Future Roadmap

- AI voice entry
- Demand forecasting
- Route optimization
- WhatsApp integration
- Delivery tracking
- Customer loyalty programs
- Inventory management
- Staff attendance
- Multi-branch support
- Advanced business intelligence

## Deployment Targets

- Android
- iOS
- Web
- Tablet
- Desktop

## Development Standards

- Production-ready implementations
- No placeholder logic
- No incomplete modules
- Complete documentation
- Reusable and modular components
- Enterprise-grade code quality
- Consistent coding standards
- Comprehensive error handling
- Maintainable codebase

## Project Goal

Deliver the most trusted and user-friendly subscription delivery management platform that preserves traditional workflows while providing modern automation, transparency, and scalability for vendors and customers.
