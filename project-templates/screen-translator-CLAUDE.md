# Screen Translator - Project Instructions

## Project Overview
Cross-platform mobile app that extracts and translates text from images using on-device ML processing.

## Tech Stack
- **Framework**: React Native 0.76
- **Language**: TypeScript
- **State**: Zustand with MMKV persistence
- **ML**: Google ML Kit (text-recognition, translate-text)
- **Monetization**: RevenueCat, Google Mobile Ads (AdMob)
- **Navigation**: React Navigation (tabs + stack)
- **i18n**: 39 language support

## Architecture
- Offline-first ML processing (no internet for core features)
- On-device text recognition and translation
- Native iOS Share Extension
- Cross-platform (iOS, Android, Web via webpack)

## Personas (Select Based on Task)
- **Mobile Developer**: UI, gestures, image handling
- **ML Engineer**: ML Kit integration, OCR accuracy
- **Monetization Engineer**: RevenueCat, AdMob
- **Platform Specialist**: iOS Share Extension, Android intents

## Code Conventions
- Functional components with hooks
- Zustand with MMKV persistence
- Service layer for ML Kit operations
- Jest for testing (218 tests)
- Responsive for tablets

## Key Principles
- Offline-first (ML Kit runs locally)
- Fast OCR processing
- Accurate translation
- Privacy-focused (no cloud processing)
- Smooth gesture interactions

## Key Features
- Image -> OCR -> Translation workflow
- Auto-detect source language
- 39 target languages
- Zoomable/draggable image view
- Translation history
- iOS Share Extension (screentranslate://share)
- Light/dark theme

## Key Commands
```bash
npm start # Start Metro bundler
npm test # Run Jest tests (218 tests)
npm run ios # Run on iOS simulator
npm run android # Run on Android emulator
```
