# BankEase · Module 2 · Complete Working Code (v0.4)

UI development and navigation: login, dashboard with four tabs, account details, a 500-row statement, fund transfer with validation, review and success screens, and an Add Beneficiary screen that returns its result. Navigation uses **go_router**. Data is hard-coded (Module 4 replaces it with an API), and balances don't change after a transfer yet (Module 3 adds shared state).

Written for **Flutter 3.24 or newer** (Dart 3.5+) and **go_router 14.x**.

---

## 1. Commands, start to finish

### 1.1 Check your setup
```bash
flutter --version          # Flutter 3.24+ / Dart 3.5+
flutter doctor             # fix anything marked ✗ for Android (and iOS on a Mac)
flutter emulators          # list emulators
flutter emulators --launch <emulator_id>
flutter devices            # the emulator should appear here
```

### 1.2 Create the project
```bash
flutter create --org com.illuminateskills --platforms android,ios bankease
cd bankease
flutter pub add go_router
```

### 1.3 Create the folder structure
```bash
# macOS / Linux / Git Bash
bash scripts/create_structure.sh
```
```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File scripts\create_structure.ps1
```
(Copy the `scripts` folder from this package into the project first, or create the folders by hand using the tree in section 2.)

### 1.4 Copy the code
Copy these from this package into your `bankease` project, replacing existing files:
- `lib/` (whole folder)
- `test/` (whole folder; this replaces the default `widget_test.dart`, which would otherwise fail)
- `pubspec.yaml`
- `analysis_options.yaml`

Then:
```bash
flutter pub get
```

### 1.5 Git workflow (as in a company)
```bash
git init
git add .
git commit -m "chore: scaffold BankEase project"

git checkout -b feature/dashboard          # v0.3 work
# ...build the dashboard files (section 4)...
git add .
git commit -m "feat(dashboard): balance card, quick actions, statement"

git checkout main
git merge feature/dashboard                # in a team: open a pull request instead

git checkout -b feature/navigation         # v0.4 work
# ...build login, transfer and router files...
git add .
git commit -m "feat(navigation): go_router, login, transfer flow"
git checkout main
git merge feature/navigation
git tag v0.4
```

### 1.6 Quality checks, run and build
```bash
flutter analyze            # should report: No issues found!
flutter test               # all tests should pass
flutter run                # runs on the connected emulator/device
# while running:  r = hot reload,  R = hot restart,  q = quit

flutter build apk --debug  # APK at build/app/outputs/flutter-apk/app-debug.apk
flutter install            # install the last build on the device
```

**Demo login:** any 8-digit customer ID (e.g. `10012345`), PIN `1234`.

---

## 2. Folder structure

```
bankease/
├── pubspec.yaml                    ← app name, version, go_router dependency
├── analysis_options.yaml           ← lint rules
├── scripts/
│   ├── create_structure.sh         ← creates lib/ folders (macOS/Linux)
│   └── create_structure.ps1        ← same for Windows
├── lib/
│   ├── main.dart                   ← entry point: runApp(BankEaseApp)
│   ├── app/
│   │   ├── app.dart                ← MaterialApp.router
│   │   ├── router.dart             ← every GoRoute in one place
│   │   ├── routes.dart             ← path constants and helpers
│   │   └── theme.dart              ← brand colour → ColorScheme
│   ├── core/                       ← shared by all features
│   │   ├── data/
│   │   │   └── mock_data.dart      ← accounts, 500 transactions, beneficiaries
│   │   ├── utils/
│   │   │   ├── money.dart          ← paise ⇄ ₹ with Indian grouping
│   │   │   ├── date_format.dart    ← dates without extra packages
│   │   │   └── validators.dart     ← all form validators
│   │   └── widgets/
│   │       ├── info_row.dart       ← label / value row
│   │       ├── section_header.dart ← title + optional "View all"
│   │       └── route_error_screen.dart
│   └── features/                   ← one folder per feature
│       ├── auth/presentation/
│       │   └── login_screen.dart
│       ├── dashboard/
│       │   ├── presentation/
│       │   │   ├── dashboard_screen.dart   ← NavigationBar + IndexedStack
│       │   │   └── home_tab.dart
│       │   └── widgets/
│       │       ├── balance_card.dart       ← Stack + gradient + hide/show
│       │       └── quick_actions.dart      ← GridView inside ListView
│       ├── accounts/
│       │   ├── domain/account.dart         ← Account + AccountType enum
│       │   └── presentation/
│       │       ├── accounts_tab.dart       ← ListView.builder
│       │       └── account_detail_screen.dart  ← path parameter :id
│       ├── transactions/
│       │   ├── domain/txn.dart
│       │   ├── presentation/statement_screen.dart  ← Expanded + ListView.separated
│       │   └── widgets/transaction_tile.dart
│       ├── transfer/
│       │   ├── domain/
│       │   │   ├── beneficiary.dart
│       │   │   └── transfer_draft.dart     ← TransferDraft, TransferReceipt
│       │   └── presentation/
│       │       ├── transfer_screen.dart            ← Form + query parameter
│       │       ├── transfer_review_screen.dart     ← receives extra
│       │       ├── transfer_success_screen.dart    ← reached with go
│       │       └── add_beneficiary_screen.dart     ← returns a result
│       ├── payments/presentation/payments_tab.dart
│       └── profile/presentation/profile_tab.dart   ← logout with go
└── test/
    ├── money_test.dart
    ├── validators_test.dart
    └── widget_test.dart
```

Why **feature-first**: everything about "transfer" lives in one folder, so a team can own it. Each feature is already split into `domain` (plain Dart models) and `presentation` (widgets). Module 4 adds a `data` folder to each feature.

---

## 3. Route map

| Path | Screen | How data arrives | Navigated with |
|---|---|---|---|
| `/login` | LoginScreen | – | `go` (after logout) |
| `/dashboard` | DashboardScreen (4 tabs) | – | `go` (after login) |
| `/dashboard/account/:id` | AccountDetailScreen | path parameter | `push` |
| `/dashboard/statement/:accountId` | StatementScreen | path parameter | `push` |
| `/dashboard/transfer?from=BE2001` | TransferScreen | query parameter | `push` |
| `/dashboard/transfer/review` | TransferReviewScreen | `extra: TransferDraft` | `push` |
| `/dashboard/transfer-success` | TransferSuccessScreen | `extra: TransferReceipt` | `go` |
| `/dashboard/beneficiaries/add` | AddBeneficiaryScreen | returns `Beneficiary` via `pop(result)` | `push<Beneficiary>` |
| anything else | RouteErrorScreen | `errorBuilder` | – |

**Why `go` after confirming a payment:** it removes Transfer and Review from the stack, so pressing Back can't take the user to a "Confirm and pay" button again.

**Why `extra` is checked:** `extra` lives only in memory. On a deep link or web refresh it is `null`, so the router shows an error screen instead of crashing.

---

## 4. Build order (teach it in this sequence)

### v0.3 · Dashboard (branch `feature/dashboard`)
| Step | Files | Concept |
|---|---|---|
| 1 | `core/utils/money.dart`, `date_format.dart` | Money in paise, formatting |
| 2 | `accounts/domain/account.dart`, `transactions/domain/txn.dart`, `transfer/domain/beneficiary.dart` | Plain Dart models |
| 3 | `core/data/mock_data.dart` | Test data; 500 rows for performance |
| 4 | `app/theme.dart`, `app/app.dart` (temporarily `MaterialApp(home: DashboardScreen())`) | Theming |
| 5 | `dashboard/widgets/balance_card.dart` | Stack, gradient, local state |
| 6 | `transactions/widgets/transaction_tile.dart` | ListTile, ellipsis |
| 7 | `core/widgets/section_header.dart`, `dashboard/widgets/quick_actions.dart` | Row + Expanded, GridView inside ListView |
| 8 | `dashboard/presentation/home_tab.dart` | One scrolling page |
| 9 | `transactions/presentation/statement_screen.dart` | Expanded + ListView.separated |
| 10 | `accounts_tab.dart`, `payments_tab.dart`, `profile_tab.dart`, `dashboard_screen.dart` | NavigationBar, IndexedStack |

### v0.4 · Navigation and forms (branch `feature/navigation`)
| Step | Files | Concept |
|---|---|---|
| 11 | `app/routes.dart`, `app/router.dart`, update `app/app.dart` | go_router, nested routes |
| 12 | `core/utils/validators.dart`, `auth/presentation/login_screen.dart` | Form, GlobalKey, controllers, `go` after login |
| 13 | `core/widgets/info_row.dart`, `accounts/presentation/account_detail_screen.dart` | Path parameters |
| 14 | `transfer/domain/transfer_draft.dart`, `transfer/presentation/transfer_screen.dart` | Query parameters, validation, `extra` |
| 15 | `transfer_review_screen.dart`, `transfer_success_screen.dart` | `go` to prevent re-submission |
| 16 | `add_beneficiary_screen.dart` | Returning a result with `pop` |
| 17 | `core/widgets/route_error_screen.dart` | `errorBuilder`, missing data |
| 18 | `test/*` | Unit and widget tests |

---

## 5. Classroom demo script (10 minutes)

1. Launch the app → login screen. Tap **Log in** with empty fields → two error messages.
2. Enter `10012345` / `1111` → "Invalid customer ID or PIN". Enter PIN `1234` → dashboard.
3. Press **Back** → the app closes (login was replaced with `go`). Reopen.
4. Tap the eye icon on the balance card → balance appears (local state).
5. Tap **View all** → statement with ~333 rows scrolls smoothly. Note the long "Online shopping…" titles end in "…".
6. **Accounts** tab → Current account → **Transfer**. The Current segment is preselected (query parameter).
7. Tap **Review transfer** without choosing anyone → "Select who to pay" plus amount errors.
8. **Add new beneficiary** → try mismatched account numbers and IFSC `BKEN1001234` → errors. Fix and save → you return with the new payee selected.
9. Enter `500.50` → **Review** → **Edit details** (back) → **Review** → **Confirm and pay** → success screen. Press Back → dashboard, not the review screen.
10. **Profile** → **Log out** → confirm → login screen. Press Back → the app closes.

---

## 6. Module 2 concept → where to find it

| Concept | File |
|---|---|
| Constraints, Row/Column, Expanded | `info_row.dart`, `section_header.dart`, `account_detail_screen.dart` |
| Stack and Positioned | `balance_card.dart` |
| GridView with shrinkWrap | `quick_actions.dart` |
| ListView.builder / separated | `accounts_tab.dart`, `statement_screen.dart` |
| Avoiding "unbounded height" | `statement_screen.dart` |
| Avoiding text overflow | `transaction_tile.dart`, `transfer_screen.dart` |
| Form, GlobalKey, validators | `login_screen.dart`, `transfer_screen.dart`, `add_beneficiary_screen.dart` |
| Input formatters | `login_screen.dart`, `add_beneficiary_screen.dart` |
| Disposing controllers | every screen with a `TextEditingController` |
| `mounted` checks after `await` | `login_screen.dart`, `transfer_screen.dart`, `quick_actions.dart` |
| NavigationBar + IndexedStack | `dashboard_screen.dart` |
| go vs push | `login_screen.dart`, `transfer_review_screen.dart`, `profile_tab.dart` |
| Path / query parameters, extra | `router.dart` |
| Returning results | `transfer_screen.dart` ↔ `add_beneficiary_screen.dart` |
| Dialogs | `profile_tab.dart` |

---

## 7. Troubleshooting

| Problem | Fix |
|---|---|
| `Target of URI doesn't exist: package:go_router` | Run `flutter pub get` (or `flutter pub add go_router`). |
| `Couldn't resolve the package 'bankease'` | The `name:` in `pubspec.yaml` must be `bankease`, matching the imports. |
| Default `widget_test.dart` fails on `MyApp` | Replace `test/` with the one in this package. |
| A newer go_router major version reports errors | Pin `go_router: ^14.6.0` in `pubspec.yaml`, run `flutter pub get`, then upgrade deliberately later. |
| No devices found | Start an emulator from Android Studio's Device Manager, then `flutter devices`. |
| Deprecation infos after upgrading Flutter | Read the message; they are warnings, not errors. Fix them as a class exercise. |
| Validation doesn't run for fields scrolled off-screen | Use `SingleChildScrollView` + `Column` for forms, not `ListView` (see `transfer_screen.dart`). |

---

## 8. Deliberately not done yet

- **Balances don't change after a transfer**, and a beneficiary added from the dashboard doesn't appear in Transfer. Each screen has its own copy of the data. → *Module 3: Riverpod shared state.*
- **No real API or error handling for networks.** → *Module 4.*
- **Login isn't secure** (no token, no secure storage, no route guard). → *Modules 5 and 7.*
- **Only a few tests.** → *Module 6.*

These gaps are intentional: they are the hooks for the next modules.
