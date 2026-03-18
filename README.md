# Food Cost Calculator

Food Cost Calculator is a lightweight Flutter app for chefs, restaurants and food businesses to calculate recipe cost, cost per serving and food cost percentage.

It is designed as a fast utility app:
- calculate recipe cost in seconds
- save recipes locally on device
- reopen saved recipes in the calculator
- edit existing recipes
- duplicate or delete recipes
- use the app as an entry point toward GastroApp for more advanced restaurant operations

## Core Features

- Recipe cost calculation
- Cost per serving calculation
- Food cost % calculation
- Multi-ingredient recipe builder
- Saved recipes stored locally with SharedPreferences
- Recipe detail view
- Reopen saved recipe into calculator
- Edit saved recipes
- Duplicate saved recipes
- Dark UI
- GastroApp upgrade CTA

## Tech Stack

- Flutter
- Dart
- SharedPreferences
- url_launcher

## Project Goal

This app is part of a broader micro-app strategy: small, useful restaurant tools that solve one problem well and can also serve as an acquisition funnel toward GastroApp.

## Current Status

MVP ready.

Current implemented flow:
1. Create recipe
2. Add ingredients
3. Calculate totals
4. Save recipe
5. Review saved recipe
6. Edit and update recipe
7. Duplicate or delete recipe

## Folder Structure

```text
lib/
  app_theme.dart
  main.dart
  pages/
  utils/
  widgets/