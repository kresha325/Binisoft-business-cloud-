# Binisoft Business Cloud

A mobile-first, multi-business SaaS management platform built with Flutter.

## Phase 1 — UI prototype
- Premium responsive dashboard
- Light and dark themes
- Business overview, catalog and services preview
- Router structure with GoRouter
- Riverpod state management
- No Firebase dependency until the UI and performance are validated

## Planned stack
Flutter / Dart · Riverpod · GoRouter · Firebase Authentication · Firestore · Storage · Cloud Functions

## Run
```bash
flutter create --project-name binisoft_business_cloud --platforms=web,android,ios .
flutter pub get
flutter run -d chrome
```

The Flutter platform scaffolding is intentionally generated with the installed SDK. Existing Dart files are not overwritten by `flutter create` by default.

## Project direction
One admin platform for restaurants, cafes, salons, shops and service businesses. Catalog items support both products and services, with tenant-scoped permissions and industry-specific fields to be added in future milestones.

## Safety
This repository contains **no Firebase production credentials** or connected customer data. Do not connect the deleted `jon-sport` Firebase project.
