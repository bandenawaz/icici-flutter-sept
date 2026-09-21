# BankEase · Module 4 · API Integration (v0.8)

Two projects:

```
BankEase_Module4/
├── bankease-api/     the backend  (Node + Express, in-memory, no database)
└── bankease/         the Flutter app, now talking to that API
```

Full explanations: **BankEase_Module4_API_Integration_Guide.docx**

## 1. Start the backend first

```bash
cd bankease-api
npm install
npm start                 # http://localhost:4000/api/v1
curl localhost:4000/api/v1/ping
```

Demo login: customer ID `10012345`, PIN `1234` (also `10067890`, same PIN).

## 2. Run the app

```bash
cd ../bankease
flutter pub add dio        # or just flutter pub get, it is already in pubspec.yaml
flutter pub get
flutter analyze
flutter test
flutter run
```

### Base URL per platform (lib/core/network/api_config.dart)

| App runs on | URL it uses |
|---|---|
| Android emulator | `http://10.0.2.2:4000/api/v1` |
| iOS Simulator / macOS | `http://localhost:4000/api/v1` |
| Real phone, same Wi-Fi | change to `http://<your-computer-ip>:4000/api/v1` |

### One-time platform settings for plain HTTP (local development only)

**Android** — `android/app/src/main/AndroidManifest.xml`, on the `<application>` tag:

```xml
<application
    android:label="bankease"
    android:usesCleartextTraffic="true"
    ...>
```

**iOS** — `ios/Runner/Info.plist`, inside the top-level `<dict>`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```

Remove both before shipping: production uses HTTPS.

## 3. What to check in class

1. Kill the backend, open the app → a friendly "No connection" screen with **Try again**.
2. Start the backend, tap Try again → accounts load.
3. Wrong PIN → the server's message appears.
4. Pull down on the dashboard → refresh.
5. Add a payee that already exists → the server's 409 message.
6. Transfer more than the balance → the server's 422 message (the app blocked it first).
7. Make it slow: `curl "localhost:4000/api/v1/dev/chaos?delayMs=3000"` → spinners.
8. Make it fail: `curl "localhost:4000/api/v1/dev/chaos?failRate=1"` → error views with retry.
9. Expire the session: `curl localhost:4000/api/v1/dev/expire-token` → next action returns to login.
10. Reset: `curl localhost:4000/api/v1/dev/chaos/reset`.

## 4. What changed in the Flutter app

**New**
- `lib/core/network/` — `api_config.dart`, `api_client.dart` (Dio + interceptors), `error_mapper.dart`
- `lib/core/errors/bank_error.dart` — sealed error types
- `lib/core/widgets/async_error_view.dart` — error + loading views
- `lib/features/*/data/*_repository.dart` — auth, accounts, transactions, beneficiaries, transfer
- `lib/features/auth/domain/session.dart`

**Changed**
- Models gained `fromJson`; `mock_data.dart` is **deleted**
- Notifiers became `AsyncNotifier` / `FutureProvider`
- Screens use `AsyncValue.when(loading, error, data)` and `RefreshIndicator`
- Login, add-beneficiary and review now call the API and show server messages
- Transfers send an `Idempotency-Key`, and the receipt (reference id, new balance) comes from the server
