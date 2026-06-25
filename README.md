# FitProgress AI

FitProgress AI is a Flutter MVP for tracking body-shape progress from periodic photo sessions. The app focuses on visual progress, posture consistency, muscle-development signals, and session-to-session comparison.

The current product is designed to stay portable across web, Android, and iOS. Platform-specific work should keep shared logic in Flutter/Dart and avoid browser-only assumptions unless they are isolated.

## Current Status

- Arabic-first single-page Flutter experience.
- Front, side, and back progress photo inputs.
- Photo readiness checks for pose stability, image clarity, and comparison quality.
- Mock analysis engine for visual progress, confidence, summary, recommendations, and warnings.
- Muscle-development breakdown for shoulders, chest, arms, and core/waist.
- Optional manual measurements for waist, chest, arm, and shoulder tracking.
- Data-quality dashboard for session count, posture stability, and AI readiness.
- History filters for all sessions, sessions with measurements, and sessions with stored photos.
- Text export/copy for session reports.
- AI-ready analysis service interface with a Supabase Edge Function provider path.
- Local persistence so sessions survive refreshes.
- Supabase persistence for `progress_sessions`.
- Supabase Storage support for progress photos instead of storing large image payloads in the database.
- Session history, session details, delete, and clear-history flows.
- Previous-session comparison support.
- Unit tests for local storage, Supabase mapping, photo readiness, and analysis behavior.

## Run Locally

Install dependencies:

```powershell
flutter pub get
```

Run in Chrome during development:

```powershell
flutter run -d chrome
```

For mobile testing from another device on the same Wi-Fi, build web and serve the static files on the fixed app port:

```powershell
flutter build web --pwa-strategy=none --no-native-null-assertions --no-web-resources-cdn
cd build\web
py -3 -m http.server 53525 --bind 0.0.0.0
```

Then open:

```text
http://YOUR_LAPTOP_IP:53525/
```

Using the same port helps keep existing browser/Supabase anonymous sessions stable.

## Supabase Setup

The app uses Supabase for remote session data and photo storage.

Required project pieces:

- Run `supabase/progress_sessions.sql` in the Supabase SQL editor.
- Enable anonymous authentication in Supabase Auth.
- Use the `progress-photos` storage bucket created by the SQL script.
- Re-run the SQL file after updates so new columns such as `muscle_metrics` are added.
- The SQL also keeps `body_measurements` ready for optional manual measurement history.
- Keep RLS policies enabled.

The Flutter app uses only the Supabase URL and publishable key. Do not place service-role keys or AI provider secrets in Flutter.

## AI Analysis Path

The app currently defaults to mock analysis:

```text
ANALYSIS_MODE=mock
```

To test the AI provider path later:

```powershell
flutter run -d chrome --dart-define=ANALYSIS_MODE=ai --dart-define=AI_ANALYSIS_FUNCTION=analyze-progress
```

Deploy the Edge Function with:

```powershell
.\scripts\deploy-analyze-progress.ps1
```

The current Edge Function is a safe placeholder that returns an AI-shaped mock result. Real provider calls should happen only inside the Supabase Edge Function, with secrets configured through Supabase:

```powershell
supabase secrets set OPENAI_API_KEY=your_key_here
```

## Quality Checks

Run these before pushing:

```powershell
flutter analyze
flutter test
flutter build web --pwa-strategy=none --no-native-null-assertions --no-web-resources-cdn
```

## Product Notes

FitProgress AI provides visual estimates and trend guidance. It is not a medical tool, not a diagnostic system, and not an exact body-composition measurement device.

## Next Work

- Replace the Edge Function placeholder with a real AI provider call.
- Add stronger QA scenarios for web, Android, and iOS.
- Improve multi-session trend charts.
- Add account/session recovery behavior when users switch devices or origins.
- Polish production hosting and environment configuration.
