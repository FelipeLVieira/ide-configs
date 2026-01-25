# BMI Calculator - Project Instructions

## Project Overview
Health tracking mobile app combining BMI calculation with comprehensive calorie/nutrition logging for iOS and Android.

## Tech Stack
- **Framework**: Expo (React Native), Managed workflow
- **Language**: TypeScript
- **State**: Zustand with AsyncStorage persistence
- **Monetization**: RevenueCat (subscriptions), Google Mobile Ads (AdMob)
- **Charts**: react-native-chart-kit
- **i18n**: i18n-js (40+ languages)
- **Deployment**: Fastlane (iOS), EAS Build

## Architecture
- Managed Expo workflow
- Zustand with persistence middleware
- Dual unit support (Metric/Imperial)
- Premium tier via RevenueCat
- All data stored locally (offline-first)

## Personas (Select Based on Task)
- **Mobile Developer**: UI components, navigation, gestures
- **Health/Fitness Expert**: BMI calculations, nutrition tracking
- **Monetization Engineer**: RevenueCat, AdMob integration
- **i18n Specialist**: Multi-language, RTL support

## Code Conventions
- Functional components with hooks
- StyleSheet for styling (not inline)
- Zustand for global state
- Jest for testing
- Responsive layouts (tablet support)

## Key Principles
- Offline-first (all data local)
- Battery-efficient
- Smooth 60fps animations
- Accessible (VoiceOver/TalkBack)
- App Store guidelines compliant

## Key Features
- BMI calculation with WHO/CDC classifications
- Meal logging (breakfast/lunch/dinner/snacks)
- Calorie and macro tracking
- Weekly/monthly/yearly charts
- Data export/import
- 40+ language support

## Key Commands
```bash
npm start              # Start Expo dev server
npm test               # Run Jest tests
npx expo build         # Build for production
```
