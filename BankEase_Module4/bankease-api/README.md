# BankEase API

A small, honest banking backend for the BankEase Flutter course (Module 4).
No database to install: everything lives in memory and resets on restart.

## Run it

```bash
cd bankease-api
npm install
npm start          # http://localhost:4000/api/v1
```

`npm run dev` restarts automatically when you edit a file (Node 18+).

Demo customers (PIN `1234` for both):

| Customer ID | Name | Accounts |
|---|---|---|
| 10012345 | Asha Rao | BE1001 (Savings, ₹4,980.50), BE2001 (Current, ₹1,25,000) |
| 10067890 | Ravi Kumar | BE3001 (Savings, ₹2,500) |

## Rules worth knowing

- **Money is always an integer number of paise.** Never a decimal.
- **Every protected call needs** `Authorization: Bearer <token>`.
- **Transfers need an `Idempotency-Key` header.** Sending the same key twice returns the
  same receipt and moves money only once.
- **Errors always look the same**, so the app can parse them:

```json
{ "error": { "code": "INSUFFICIENT_FUNDS", "message": "Insufficient funds",
             "details": { "shortByPaise": 401950 }, "traceId": "..." } }
```

## Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/ping` | Health check, no token |
| POST | `/auth/login` | `{ customerId, pin }` → `{ token, expiresInSeconds, customer }` |
| POST | `/auth/logout` | Invalidates the token (204) |
| GET | `/accounts` | `{ items: [...] }` |
| GET | `/accounts/:id` | 404 unknown, 403 if it belongs to someone else |
| GET | `/accounts/:id/transactions?page=0&size=20` | `{ items, page, size, total, hasMore }` |
| GET | `/beneficiaries` | `{ items: [...] }` |
| POST | `/beneficiaries` | 201 created, 400 invalid, 409 duplicate |
| DELETE | `/beneficiaries/:id` | 204, or 404 |
| POST | `/transfers` | 201 created, 200 replay, 409 key reuse, 422 rule broken |

### Error codes

| HTTP | code | When |
|---|---|---|
| 400 | `BAD_REQUEST` | Missing or invalid fields (`details` has the field errors) |
| 401 | `UNAUTHORIZED` | No token, invalid token, expired session |
| 403 | `FORBIDDEN` | The resource belongs to another customer |
| 404 | `NOT_FOUND` | Unknown account, beneficiary or URL |
| 409 | `BENEFICIARY_EXISTS` | That account number is already saved |
| 409 | `IDEMPOTENCY_KEY_REUSED` | Same key, different transfer |
| 422 | `INSUFFICIENT_FUNDS` | Not enough money (`details.shortByPaise`) |
| 422 | `LIMIT_EXCEEDED` | Over ₹1,00,000 per transfer |
| 422 | `INVALID_AMOUNT` | Zero or negative |
| 500 | `SERVER_ERROR` | Unexpected failure (also used by the chaos switch) |
| 503 | `SERVICE_UNAVAILABLE` | Chaos switch: `down=true` |

## Teaching switches

Use these in class to show loading, error and retry states in the app.

```bash
curl "localhost:4000/api/v1/dev/chaos?delayMs=3000"   # every call takes 3 seconds
curl "localhost:4000/api/v1/dev/chaos?failRate=0.5"   # half the calls return 500
curl "localhost:4000/api/v1/dev/chaos?down=true"      # every call returns 503
curl "localhost:4000/api/v1/dev/chaos/reset"          # back to normal
curl "localhost:4000/api/v1/dev/expire-token"         # next protected call returns 401
```

## Connecting the Flutter app

| Where the app runs | Base URL |
|---|---|
| Android emulator | `http://10.0.2.2:4000/api/v1` |
| iOS Simulator / macOS / desktop | `http://localhost:4000/api/v1` |
| Real phone on the same Wi-Fi | `http://<your-computer-IP>:4000/api/v1` |

Android blocks plain HTTP by default. The Flutter project's
`android/app/src/main/AndroidManifest.xml` needs
`android:usesCleartextTraffic="true"` on `<application>` for local development only.

## Files

```
bankease-api/
├── server.js               app setup, logging, chaos, error shape
├── package.json
├── requests.http           ready-made requests (VS Code REST Client)
└── src/
    ├── db.js               in-memory data + seeding
    ├── errors.js           ApiError and helpers
    ├── auth.js             tokens, login, requireAuth middleware
    └── routes/
        ├── auth.js  accounts.js  beneficiaries.js  transfers.js  dev.js
```
