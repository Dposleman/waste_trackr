# WasteTrackr

WasteTrackr is a lightweight Flutter app for chefs, restaurants, and food businesses to track food waste, measure financial loss, and improve kitchen visibility.

It is designed as a fast utility app inside the UnderStack ecosystem.

## Current Goal

This repository is the MVP base for the second micro-app in the UnderStack utility portfolio.

Current implemented flow:

1. Add waste entries
2. Save entries locally on device
3. View live dashboard totals
4. Review history with filters
5. Delete entries from history

## Core Features

- Waste entry logging
- Loss calculation per entry
- Daily waste total
- Weekly waste total
- Top waste reason
- Top loss item
- Local persistence with SharedPreferences
- Search and filter in history
- Delete saved entries
- Premium UnderStack dark UI

## Planned Next Features

- Edit saved entries
- Category analytics
- Date-range filtering
- GastroApp upgrade funnel
- Export options
- Play Store release assets

## Tech Stack

- Flutter
- Dart
- SharedPreferences
- url_launcher

## Project Goal

This app is part of a broader micro-app strategy: small, useful restaurant tools that solve one problem well and can also work as an acquisition funnel toward GastroApp.

## Folder Structure

```text
lib/
  app_theme.dart
  main.dart
  models/
  pages/
  services/
  utils/
  widgets/