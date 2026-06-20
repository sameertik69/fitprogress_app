# FitProgress AI

FitProgress AI is a Flutter MVP for tracking body progress through standardized progress photos.

The current goal is to build the app step by step, test each stage, and keep the workflow simple before adding backend, authentication, storage, or real analysis.

## Current Status

The app currently runs as a local Flutter Web prototype.

Implemented so far:

- A clean first screen for body progress tracking.
- Arabic RTL interface.
- Three required progress photo slots:
  - Front photo
  - Side photo
  - Back photo
- Image selection from the device using `image_picker`.
- Preview for each selected photo.
- Disabled scan button until all three photos are selected.
- A demo progress report after pressing the scan button.
- Safe product wording:
  - visual progress estimate
  - confidence score
  - posture consistency
  - ratio change
- Clear warning that results are visual estimates, not medical measurements or exact muscle mass measurement.

## Demo Report

The current report is mock/demo data only. It shows:

- Visual progress estimate
- Confidence score
- Shoulder-to-waist ratio change
- Posture consistency score
- A short summary explaining the result

No real AI, pose detection, Supabase, or storage is connected yet.

## How To Run

Install Flutter, then run:

```bash
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 53504
```

Open:

```text
http://127.0.0.1:53504
```

You can also run with any available port:

```bash
flutter run -d web-server
```

## Checks

Before pushing changes, run:

```bash
flutter analyze
flutter test
```

Both checks passed at the current stage.

## Next Steps

Planned work:

- Improve the photo selection UX.
- Add a dedicated scan/loading state.
- Move the demo report into a cleaner report screen or section.
- Add basic photo quality guidance.
- Add camera capture support.
- Add local session state.
- Add Supabase Auth later.
- Add Supabase Storage for uploaded photos.
- Add Supabase Database tables for progress sessions.
- Add pose landmark extraction.
- Add real image-based comparison logic.
- Add timeline/history for previous sessions.

## Important Product Note

This app must not claim exact muscle mass measurement.

Use wording such as:

- visual progress estimate
- image-based comparison
- body ratio change
- confidence score

Avoid wording that suggests medical diagnosis, body composition accuracy, or exact muscle measurement.
