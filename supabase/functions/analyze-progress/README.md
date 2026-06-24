# analyze-progress

Supabase Edge Function placeholder for future AI body progress analysis.

Current behavior:
- Accepts structured metadata from the Flutter app.
- Returns a valid `AnalysisResult`-shaped mock response.
- Does not call an external AI provider yet.

Future OpenAI setup:
- Store `OPENAI_API_KEY` as a Supabase secret.
- Call OpenAI from this Edge Function only.
- Never put AI provider secrets in the Flutter app.

Deploy later with:

```powershell
supabase functions deploy analyze-progress
```

## Local Serve

From the project root, after installing and logging in with Supabase CLI:

```powershell
supabase functions serve analyze-progress --env-file .env.local
```

The function currently returns a mock AI-shaped result from the Edge Function.

## Flutter AI Mode

The Flutter app defaults to local mock analysis.

To point Flutter at this Edge Function path in the future:

```powershell
flutter run -d chrome --dart-define=ANALYSIS_MODE=ai --dart-define=AI_ANALYSIS_FUNCTION=analyze-progress
```

Keep the default mode as `mock` until the Edge Function is deployed and tested.

## Secrets

When a real AI provider is added, configure secrets in Supabase, not Flutter:

```powershell
supabase secrets set OPENAI_API_KEY=your_key_here
```

Do not commit `.env.local` or provider secrets.
