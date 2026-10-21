# TODO

Plan: `docs/FLUTTER-KURYER-APP-PLAN.md` in [gurularavel/omnidlv](https://github.com/gurularavel/omnidlv). Backend API: `docs/COURIER-MOBILE-API.md` there.

## Done in v1 (this repo)

- [x] Sign-in: phone (digits only, live format) → SMS code → token in Keychain/Keystore
- [x] Home: next stop, time left, address, map strip, call, Google Maps / Waze choice, primary step, "My day" (active / pool / done), take from pool
- [x] Task: details, items, barcode scan, proof photo (compressed on device), signature, SMS code check, handover in two taps, "could not deliver"
- [x] Offline queue for actions (`X-Action-Id`, replayed when the network returns)
- [x] GPS while the shift is open: Android foreground service, iOS background location, batched, buffered offline, battery level, mock-location flag
- [x] Permission flow with prominent disclosure (location → always → notifications → battery optimisation)
- [x] Forced update (`min_version` from `/app-config`), 4 languages (az, en, ru, tr), account deletion request
- [x] Tests: phone formatter, model parsing, offline queue, sign-in screen

## Next stage: stores (needs accounts, see plan section 1)

- [ ] Apple Developer + Google Play **organization** accounts (D-U-N-S number first; it takes 1–2 weeks)
- [ ] App icon and splash (brand assets), store screenshots in 4 languages, short and long descriptions
- [ ] Privacy policy page on the OmniDLV domain; set `COURIER_APP_PRIVACY_URL`
- [ ] Release signing: Android upload keystore (keep it outside the repo), iOS certificates / provisioning via Xcode or Fastlane match
- [ ] Production API URL: build with `--dart-define=API_BASE_URL=https://app.<domain>` (HTTPS only; cleartext is debug-only)
- [ ] Reviewer account: set `COURIER_REVIEW_PHONE` / `COURIER_REVIEW_CODE` on the server, pointing at a courier in a demo company
- [ ] Google Play: Location permissions declaration + 30 s video of the disclosure → permission → shift → location on the panel with the screen off; foreground service (location) declaration; Data safety form
- [ ] App Store: background location justification in review notes, App Privacy answers (precise location, photos, phone, name; not used for tracking)
- [ ] TestFlight + Play internal testing with real couriers, then production
- [ ] Set `COURIER_APP_PLAY_URL` / `COURIER_APP_APPSTORE_URL` / `COURIER_APP_LATEST_VERSION` on the server after release

## Next stage: features and hardening

- [ ] Decide the GPS library: Transistorsoft `flutter_background_geolocation` (paid Android licence, best on Xiaomi/Samsung) or keep `geolocator`. Test on real Samsung, Xiaomi, an old Android and an iPhone with the screen locked for 1 h.
- [ ] iOS: when the Podfile is generated on a Mac, enable permission_handler's permissions in `post_install`:
  ```ruby
  target.build_configurations.each do |config|
    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)',
      'PERMISSION_LOCATION=1', 'PERMISSION_LOCATION_WHENINUSE=0', 'PERMISSION_CAMERA=1',
      'PERMISSION_NOTIFICATIONS=1', 'PERMISSION_PHOTOS=1']
  end
  ```
- [ ] Push notifications: Firebase project (android + ios apps), `firebase_messaging`, APNs key; server: FCM push driver in place of `log`
- [ ] Brand fonts (Fira Sans / Fira Sans Condensed as TTF assets)
- [ ] Move the offline queue and GPS buffer from SharedPreferences to SQLite (drift) once volumes grow
- [ ] Crash reporting (Sentry or Crashlytics)
- [ ] CI: GitHub Actions running `flutter analyze` + `flutter test`; Fastlane / Codemagic for builds (iOS needs macOS)
- [ ] Panel: "no signal for N minutes" marker for couriers whose last fix is old; list of account deletion requests
