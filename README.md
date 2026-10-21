# OmniDLV Kuryer

Native courier app (Flutter, Android + iOS) for [OmniDLV](https://github.com/gurularavel/omnidlv). It replaces the browser app (PWA) so the courier's position keeps reaching dispatch with the screen off or while Waze is in front.

The app holds no business rules: every step (pick up, on the way, arrived, handover, failure), capacity, delivery codes and proof go through the server's courier API (`/api/courier/v1`, see `docs/COURIER-MOBILE-API.md` in the omnidlv repo), the same code paths the PWA uses.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8090   # Android emulator → local server
flutter test
flutter analyze
```

`API_BASE_URL` defaults to `http://10.0.2.2:8090`. Release builds must use HTTPS: cleartext traffic is only allowed in debug builds.

Sign in with a courier's phone number. While the server's SMS runs in demo mode the code is shown on screen.

## Layout

```
lib/
  core/        config, API client, token store, offline action queue, phone formatter
  data/        API models and repository (one method per endpoint)
  services/    background GPS (batched, buffered offline), Google Maps / Waze launcher
  state/       Riverpod providers: session, board, task, locale
  ui/          screens: sign-in, home, task, permissions, scan, update; sheets
  l10n/        az, en, ru, tr (ARB; generated code in l10n/generated)
```

## Location tracking

- Starts when the shift starts, stops when it ends. Nothing is tracked off shift.
- Android: foreground service with an ongoing notification ("OmniDLV: you are on shift").
- iOS: background location with the blue indicator; needs "Always" permission.
- Every 15 s / 30 m while a task is on the road, every 60 s / 100 m otherwise (server-configurable).
- Fixes are buffered on the phone and sent in batches; offline fixes are sent later and the server never moves the courier back to an older point.

## Store release

Not done yet. See [TODO.md](TODO.md).
