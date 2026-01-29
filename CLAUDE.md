# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ProfConnect (codename: supernova) is a Ruby on Rails 8 app connecting French parents with certified Éducation Nationale teachers for tutoring. Only real licensed teachers can register — no students. The app is in French by default.

## Common Commands

```bash
bin/dev                                # Start dev server (Rails + Tailwind watcher + GoodJob worker)
bin/rails test                         # Run all tests
bin/rails test test/path/to_test.rb    # Run a single test file
bin/rails test test/path/to_test.rb:42 # Run a single test at line number
bin/rails test:system                  # Run system tests (Capybara + Selenium)
bin/rubocop                            # Lint Ruby (Omakase style)
bin/brakeman                           # Security scan
bin/rails db:migrate                   # Run pending migrations
```

## Architecture

### Two-Sided Marketplace with Role-Based Routing

Users have a single `User` model (Devise) with a `role` enum: `parent` or `teacher`. Each role has:
- **Separate signup flows**: `Parents::RegistrationsController` and `Teachers::RegistrationsController`
- **Separate dashboards**: parents see `/teachers` (listing), teachers see `/dashboard/teacher`
- **Separate profile models**: `ParentProfile` and `Teacher` (linked to `User`)
- **Role-based redirects** in `SessionsController#after_sign_in_path_for`

### Teacher Verification Flow

Teachers go through an admin approval workflow:
1. Teacher signs up and submits profile + verification documents (`TeacherDocument` via Cloudinary)
2. Status starts as `pending`, admin reviews at `/admin/teachers`
3. Admin can `approve` or `reject` via `Admin::TeachersController`

### Request & Messaging System

Parents create tutoring `Request`s for a specific teacher+student+subject. Requests have statuses: `pending` → `accepted`/`declined`. Messages are nested under requests. Teachers manage requests via the `Teacher::RequestsController` namespace.

### Key Patterns

- **Authorization**: Pundit policies in `app/policies/`
- **Notifications**: Service objects in `app/services/notifications/` (WelcomeNotifier, RequestNotifier, MessageNotifier) sending emails via `NotificationMailer`
- **Background jobs**: GoodJob (PostgreSQL-backed, no Redis needed)
- **Layouts**: `application.html.erb` for public pages, `authenticated.html.erb` for logged-in pages

### Frontend Stack

- Tailwind CSS + DaisyUI 5 for UI components
- Stimulus.js controllers in `app/javascript/controllers/`
- Turbo for navigation
- Importmap (no JS bundler)
- Propshaft asset pipeline

### Deployment

- Kamal (Docker-based) configured in `config/deploy.yml`
- Production domain: `www.prof-connect.fr`
- File storage: Cloudinary for images, S3 in production
- CI: GitHub Actions runs brakeman, rubocop, importmap audit, and full test suite with PostgreSQL
