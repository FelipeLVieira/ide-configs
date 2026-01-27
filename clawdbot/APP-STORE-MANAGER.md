# App Store Manager — Automated iOS App Monitoring

## Overview

Clawdbot cron job that monitors all 3 iOS apps on App Store Connect. Checks review status, ratings, builds, and policy compliance 3x daily.

## Schedule

| Time (EST) | Cron Expression | Purpose |
|------------|-----------------|---------|
| 9:00 AM | `0 9 * * *` | Morning check (catches overnight rejections) |
| 3:00 PM | `0 15 * * *` | Afternoon check (mid-day status) |
| 9:00 PM | `0 21 * * *` | Evening check (end-of-day wrap-up) |

**Timezone**: America/New_York (EST/EDT)
**Model**: gpt-oss:20b (local, FREE)
**Machine**: MacBook Pro (main session)

## Apps Monitored

| App | Bundle ID | Current Version | Store Status |
|-----|-----------|-----------------|--------------|
| **BMI & Calorie Tracker** | `com.felipevieira.bmicalculator` | v2.1.1 | Published |
| **Bills Tracker** | `com.fullstackdev1.bill-subscriptions-organizer-tracker` | v1.0.6 | Published |
| **Offline Image Translator** | `com.felipevieira.screentranslate` | v1.0.0 | Published |

## Credentials

| Field | Value |
|-------|-------|
| **Team ID** | `824F44HKCD` |
| **API Keys** | `~/.private_keys/AuthKey_*.p8` |
| **Issuer ID** | WARNING: **MISSING** — Felipe needs to provide |

### Getting the Issuer ID

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** -> **Integrations** -> **App Store Connect API**
3. Copy the **Issuer ID** from the top of the page
4. Provide it to the bot for configuration

## Fastlane Setup

| App | Fastlane Configured | Notes |
|-----|---------------------|-------|
| BMI Calculator | [OK] Yes | Full pipeline (build, upload, metadata) |
| Bills Tracker | [OK] Yes | Full pipeline |
| Screen Translator | [NO] Not yet | Needs Fastlane init |

## Checks Performed

Each run performs these checks via App Store Connect API:

### 1. Review Status
- Check if any app is `Waiting for Review`, `In Review`, `Rejected`, or `Developer Action Needed`
- Track time in review queue

### 2. Ratings & Reviews
- Monitor star ratings (alert if average drops below 4.0)
- Flag new 1-2 star reviews for immediate attention
- Track review count trends

### 3. Screenshots & Metadata
- Verify all required screenshot sizes are uploaded
- Check for missing localization data
- Validate app descriptions and keywords

### 4. Pricing & IAP
- Verify pricing tier hasn't changed unexpectedly
- Check in-app purchase status and approvals
- Monitor subscription metrics (if applicable)

### 5. Build Status
- Check for expired builds (TestFlight builds expire after 90 days)
- Verify latest build is processing/ready
- Track build version numbers

### 6. Policy Compliance
- Monitor for Apple policy update notifications
- Check for required SDK updates or privacy manifest changes
- Track minimum OS version requirements

## Alert Rules

| Event | Severity | Notify | Channel |
|-------|----------|--------|---------|
| **App Rejected** | [CRITICAL] Critical | Felipe directly | Telegram DM |
| **Bad Review (1-2 stars)** | [WARNING] Warning | Dev team | Telegram group |
| **Build Expired** | [WARNING] Warning | Dev team | Telegram group |
| **Rating Below 4.0** | [WARNING] Warning | Felipe + dev team | Telegram group |
| **Review Status Change** | Info | Dev team | Telegram group |
| **Policy Update Required** | Important | Felipe | Telegram DM |

## API Usage

Uses the [App Store Connect API v2](https://developer.apple.com/documentation/appstoreconnectapi):

```bash
# Generate JWT token
jwt encode \
  --iss "$ISSUER_ID" \
  --exp "+20m" \
  --aud "appstoreconnect-v1" \
  --key "$API_KEY_PATH" \
  --kid "$KEY_ID"

# Example: Check app status
curl -H "Authorization: Bearer $JWT_TOKEN" \
  "https://api.appstoreconnect.apple.com/v1/apps"
```

## Cron Configuration

```bash
# Add via Clawdbot CLI
clawdbot cron add \
  --name "app-store-manager" \
  --schedule "0 9,15,21 * * *" \
  --model "ollama/gpt-oss:20b" \
  --prompt "Check App Store Connect for all 3 iOS apps. Report any status changes, new reviews, or issues."
```

## TODO

- [ ] Get Issuer ID from Felipe (App Store Connect -> Users -> Integrations -> API)
- [ ] Set up Fastlane for Screen Translator
- [ ] Configure webhook for real-time rejection alerts (instead of polling)
- [ ] Add App Store Connect metrics to clawd-monitor dashboard

## References

- [Dev Teams](../dev-teams.md) — iOS app team roles
- [Clawdbot Config](../clawdbot-config.md) — Cron job configuration
- [Three-Machine Architecture](../infrastructure/three-machine-architecture.md) — Infrastructure overview
