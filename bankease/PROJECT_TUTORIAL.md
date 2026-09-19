# BankEase: Complete Flutter Project Tutorial

This tutorial explains the BankEase project from the first Dart statement to the final transfer flow. It is written as a code walkthrough for a beginner-to-intermediate Flutter developer.

The project is a deliberately small banking demo. It demonstrates:

- Flutter app startup and Material 3 theming
- Feature-first folder organization
- Plain Dart domain models
- Hard-coded mock data
- `go_router` navigation
- Forms, validation, controllers, and input formatters
- Dashboard tabs and scrolling layouts
- A multi-screen transfer workflow
- Riverpod state-management scaffolding
- Unit and widget tests

The app is not connected to a real bank. Login and transfer requests are simulated with short delays.

## 1. What You Will Build

At the end of the walkthrough, the user can:

1. Open the app on the login screen.
2. Enter an eight-digit customer ID and the demo PIN `1234`.
3. Browse a four-tab dashboard.
4. Hide and show an account balance.
5. Open account details and a generated statement.
6. Start a transfer from a selected account.
7. Add a beneficiary and return it to the transfer form.
8. Validate the amount and beneficiary details.
9. Review and confirm a transfer.
10. View a generated receipt and return to the dashboard.
11. Log out and return to the login screen.

The current version intentionally does not persist users, call an API, or update balances after a transfer.

## 2. Prerequisites

Install the following:

| Requirement | Expected version | Check |
|---|---|---|
| Flutter | 3.24 or newer | `flutter --version` |
| Dart | 3.5 or newer | Included with Flutter |
| Xcode | Current macOS-compatible version | `xcodebuild -version` |
| iOS Simulator or Android emulator | Any supported device | `flutter devices` |
| Git | Any recent version | `git --version` |

Run the environment check:

```bash
flutter doctor
flutter devices
```

For macOS iOS development, accept the Xcode license if Flutter reports that it is required:

```bash
sudo xcodebuild -license
```

Keep the project outside a cloud-synchronized or file-provider folder when building for iOS. Some macOS file providers add Finder metadata to generated `.framework` bundles, and Apple codesigning rejects that metadata. A local folder such as `~/Developer` is a good choice.

## 3. Run the Existing Project

From the `bankease` directory:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To select a named iOS simulator:

```bash
flutter run -d "iPhone 16e"
```

The project currently uses these direct dependencies:

- `go_router` for declarative navigation
- `flutter_riverpod` for the next shared-state layer
- `cupertino_icons` for icon support

They are declared in [`pubspec.yaml`](pubspec.yaml).

## 4. Understand the Architecture First

BankEase uses four broad layers:

```text
main.dart
  |
  v
ProviderScope -> BankEaseApp
                  |
                  +-> ThemeData
                  +-> GoRouter
                  +-> feature screens

core/       Shared data, utilities, and reusable widgets
features/   User-facing capabilities grouped by feature
app/        App shell, routes, router, and theme
test/       Unit and widget tests
```

The important architectural choice is feature-first organization. A transfer screen, its transfer models, and its transfer-specific behavior are grouped under `features/transfer`. Shared concerns stay under `core`.

## 5. Read the Project Tree

```text
bankease/
├── pubspec.yaml
├── analysis_options.yaml
├── scripts/
│   ├── create_structure.sh
│   └── create_structure.ps1
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   ├── core/
│   │   ├── data/mock_data.dart
│   │   ├── utils/
│   │   │   ├── date_format.dart
│   │   │   ├── money.dart
│   │   │   └── validators.dart
│   │   └── widgets/
│   │       ├── info_row.dart
│   │       ├── route_error_screen.dart
│   │       └── section_header.dart
│   └── features/
│       ├── auth/
│       ├── accounts/
│       ├── dashboard/
│       ├── payments/
│       ├── profile/
│       ├── transactions/
│       └── transfer/
└── test/
```

When learning the code, follow this order:

1. `main.dart`
2. `app/app.dart`, `app/theme.dart`, and `app/router.dart`
3. `core/data/mock_data.dart` and `core/utils/`
4. Domain models
5. Dashboard screens and widgets
6. Login and transfer screens
7. Riverpod providers
8. Tests

## 6. Step One: Application Startup

Open [`lib/main.dart`](lib/main.dart).

```dart
void main() {
  runApp(const ProviderScope(child: BankEaseApp()));
}
```

Dart starts at `main()`. `runApp` inserts the root widget into Flutter's widget tree.

`ProviderScope` comes from Riverpod. It creates the container in which providers can store and expose state. Even though most current screens still read `MockData` directly, placing `ProviderScope` at the root prepares the app for shared state.

The root application widget is [`lib/app/app.dart`](lib/app/app.dart):

```dart
return MaterialApp.router(
  title: 'BankEase',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  routerConfig: appRouter,
);
```

`MaterialApp.router` delegates navigation to `go_router` instead of using a single `home:` widget.

### Checkpoint

Run the app and confirm that the first screen is the login screen. The initial location is configured in [`lib/app/router.dart`](lib/app/router.dart), not in `main.dart`.

## 7. Step Two: Theme and Shared Presentation

Open [`lib/app/theme.dart`](lib/app/theme.dart).

```dart
static const Color brandGreen = Color(0xFF0E6B5C);

static final ThemeData light = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: brandGreen),
);
```

The app defines one brand color and asks Material 3 to derive the rest of the color scheme. Screens use `Theme.of(context)` so they do not hard-code the same colors repeatedly.

Shared widgets reduce repeated layout code:

- [`lib/core/widgets/info_row.dart`](lib/core/widgets/info_row.dart) displays a label and value pair.
- [`lib/core/widgets/section_header.dart`](lib/core/widgets/section_header.dart) displays a section title and optional action.
- [`lib/core/widgets/route_error_screen.dart`](lib/core/widgets/route_error_screen.dart) handles invalid routes and missing data.

The reusable `RouteErrorScreen` is important because route data can be missing or invalid. A screen should display a useful state instead of crashing with a null assertion.

## 8. Step Three: Model Money Safely

Open [`lib/core/utils/money.dart`](lib/core/utils/money.dart).

BankEase stores money as integer paise:

```text
₹49.85 -> 4985 paise
```

This avoids floating-point rounding problems. The main helpers are:

- `formatRupees(4985)` returns `₹49.85`.
- `formatRupees(-49900)` returns `-₹499.00`.
- `parseRupeesToPaise('49.85')` returns `4985`.

The parser removes commas, accepts zero to two decimal places, and returns `null` for invalid input. The function never converts user money through `double`.

The Indian grouping algorithm formats values such as:

```text
1234567890 paise -> ₹1,23,45,678.90
```

This behavior is covered by [`test/money_test.dart`](test/money_test.dart).

## 9. Step Four: Define Plain Dart Domain Models

Domain models describe the data without knowing about Flutter widgets.

### Account

[`lib/features/accounts/domain/account.dart`](lib/features/accounts/domain/account.dart) defines:

- `AccountType.savings` and `AccountType.current`
- account identity and bank details
- integer balance in paise
- `maskedNumber` for safe display
- `copyWith` for immutable balance changes

`copyWith` creates a new `Account`; it does not mutate the original object.

### Transaction

[`lib/features/transactions/domain/txn.dart`](lib/features/transactions/domain/txn.dart) defines a transaction with:

- account ID
- title
- signed amount in paise
- date
- payment mode

A negative amount is a debit, and `isDebit` exposes that rule to the UI.

### Beneficiary and transfer objects

[`lib/features/transfer/domain/beneficiary.dart`](lib/features/transfer/domain/beneficiary.dart) defines a payee and provides masked account numbers and initials.

[`lib/features/transfer/domain/transfer_draft.dart`](lib/features/transfer/domain/transfer_draft.dart) contains the two objects passed through the transfer flow:

- `TransferDraft`: what the user is about to send
- `TransferReceipt`: what the demo bank returns after confirmation

These objects make data passed between screens explicit and type-safe.

## 10. Step Five: Load Mock Data

[`lib/core/data/mock_data.dart`](lib/core/data/mock_data.dart) is the temporary data source.

It provides:

- customer `Asha Rao`
- customer ID `10012345`
- two accounts
- three beneficiaries
- 500 generated transactions

The transaction generator deliberately creates enough rows to demonstrate a lazy list. The statement does not need 500 handwritten objects.

The current data path is:

```text
MockData.accounts
MockData.transactions
MockData.beneficiaries
        |
        v
screens read and display the values
```

This is simple for a learning module, but it means different screens can hold separate copies of data. Module 3 is intended to replace this with shared state, and Module 4 with repositories and an API.

## 11. Step Six: Add Shared Utilities

[`lib/core/utils/date_format.dart`](lib/core/utils/date_format.dart) formats dates without adding another package:

- `formatDate` produces `16 Sep 2026`.
- `formatDateTime` produces `16 Sep 2026, 6:30 PM`.
- `greetingFor` produces `morning`, `afternoon`, or `evening`.

[`lib/core/utils/validators.dart`](lib/core/utils/validators.dart) centralizes form rules. Flutter validators follow one contract:

```text
return null       valid value
return 'message'  invalid value shown by the field
```

The validators cover:

- eight-digit customer IDs
- four-digit PINs
- positive transfer amounts
- maximum transfer value of ₹1,00,000
- available balance
- remarks length and allowed characters
- beneficiary names
- account numbers
- matching account numbers
- IFSC format

Keeping these rules outside the widgets makes them reusable and easy to test.

## 12. Step Seven: Build the Dashboard

[`lib/features/dashboard/presentation/dashboard_screen.dart`](lib/features/dashboard/presentation/dashboard_screen.dart) owns the selected tab:

```dart
int _index = 0;
```

It combines `NavigationBar` with `IndexedStack`:

```dart
body: IndexedStack(
  index: _index,
  children: const [
    HomeTab(),
    AccountsTab(),
    PaymentsTab(),
    ProfileTab(),
  ],
),
```

`IndexedStack` keeps all tabs alive. When the user switches tabs and comes back, scroll positions are preserved.

### Home tab

[`lib/features/dashboard/presentation/home_tab.dart`](lib/features/dashboard/presentation/home_tab.dart) is one scrolling `ListView` containing:

1. the primary account balance card
2. quick actions
3. five recent transactions

The page uses `context.push` for details and statements.

### Balance card

[`lib/features/dashboard/widgets/balance_card.dart`](lib/features/dashboard/widgets/balance_card.dart) demonstrates local widget state:

```dart
bool _hidden = true;
```

The balance is hidden by default. Tapping the eye icon calls `setState` and changes only this card.

The visual composition uses:

- `Material` for touch behavior
- a `LinearGradient` for the card background
- `Stack` and `Positioned` for the faded bank icon
- `Expanded` so the balance text and eye button fit on one row

### Quick actions

[`lib/features/dashboard/widgets/quick_actions.dart`](lib/features/dashboard/widgets/quick_actions.dart) places a non-scrolling `GridView.count` inside the home `ListView`.

The two important properties are:

```dart
shrinkWrap: true,
physics: NeverScrollableScrollPhysics(),
```

The grid sizes itself to its content and lets the outer page own scrolling. Without these settings, nested scrolling and unbounded-height errors are common.

### Accounts and statements

`AccountsTab` uses `ListView.builder`, which lazily builds account rows.

`StatementScreen` uses `ListView.separated` for the generated transaction list. Because the list is inside a `Column`, it must be wrapped in `Expanded`; otherwise Flutter cannot calculate its vertical viewport height.

## 13. Step Eight: Configure Navigation

The route names live in [`lib/app/routes.dart`](lib/app/routes.dart). Screens call helpers such as:

```dart
AppRoutes.account(account.id)
AppRoutes.statement(account.id)
AppRoutes.transfer(fromAccountId: account.id)
```

This prevents path strings from being duplicated throughout the app.

The route tree is defined in [`lib/app/router.dart`](lib/app/router.dart):

| Path | Screen | Data mechanism |
|---|---|---|
| `/login` | `LoginScreen` | none |
| `/dashboard` | `DashboardScreen` | none |
| `/dashboard/account/:id` | `AccountDetailScreen` | path parameter |
| `/dashboard/statement/:accountId` | `StatementScreen` | path parameter |
| `/dashboard/transfer?from=BE2001` | `TransferScreen` | query parameter |
| `/dashboard/transfer/review` | `TransferReviewScreen` | `state.extra` |
| `/dashboard/transfer-success` | `TransferSuccessScreen` | `state.extra` |
| `/dashboard/beneficiaries/add` | `AddBeneficiaryScreen` | result returned with `pop` |

### `go` versus `push`

Use `push` when the user should be able to return to the previous screen:

```dart
context.push(AppRoutes.transferReview, extra: draft);
```

Use `go` when the previous screen should no longer be reachable through Back:

```dart
context.go(AppRoutes.dashboard);
```

Login uses `go` so Back cannot reveal the login form after authentication. Transfer confirmation uses `go` so Back cannot reopen a payment confirmation screen and accidentally submit it again. Logout also uses `go` so Back cannot reveal the authenticated dashboard.

### Route data safety

`state.extra` exists only in memory. It can be missing after a deep link or web refresh. The router checks its type before constructing review and success screens. Missing data produces `RouteErrorScreen` instead of a crash.

## 14. Step Nine: Understand Login

[`lib/features/auth/presentation/login_screen.dart`](lib/features/auth/presentation/login_screen.dart) is a `StatefulWidget` because it owns:

- a `Form` key
- two text controllers
- PIN visibility state
- a submitting state

The form flow is:

```text
Tap Log in
  |
  +-> unfocus keyboard
  +-> validate customer ID and PIN
  +-> show loading state
  +-> wait 800 ms to simulate a server
  +-> check PIN == 1234
  +-> go to dashboard
```

Every `TextEditingController` is disposed in `dispose()`.

The `mounted` check after the fake asynchronous request prevents `setState` from running if the screen was removed while the request was in progress.

Demo credentials:

- Customer ID: any eight digits, such as `10012345`
- PIN: `1234`

The current login is only a UI demonstration. It does not create a session or authenticate against a server.

## 15. Step Ten: Follow the Transfer Workflow

The transfer feature is the richest flow in the project.

```text
Payments or account details
        |
        v
TransferScreen
        |
        +-- choose account from query parameter
        +-- choose beneficiary
        +-- optionally add beneficiary
        +-- validate amount and remarks
        v
TransferReviewScreen
        |
        +-- edit details with pop
        +-- confirm with fake delay
        v
TransferSuccessScreen
        |
        v
Dashboard
```

### 15.1 Start the transfer

`TransferScreen` accepts `fromAccountId` from the query string. If the ID is missing or unknown, it falls back to the first account.

For example:

```text
/dashboard/transfer?from=BE2001
```

The screen keeps a local beneficiary list:

```dart
final List<Beneficiary> _beneficiaries = [...MockData.beneficiaries];
```

The spread creates a new list for this screen. It is intentionally local in the current module.

### 15.2 Add a beneficiary and return a result

The transfer screen pushes the add screen with a type parameter:

```dart
final added = await context.push<Beneficiary>(AppRoutes.addBeneficiary);
```

The add screen validates its form, creates a `Beneficiary`, and returns it:

```dart
context.pop(beneficiary);
```

The transfer screen receives the result after `await`, checks `mounted`, adds the beneficiary, and selects it.

If the user presses Back instead of saving, the result is `null` and the transfer screen does nothing.

### 15.3 Validate and create a draft

When the user taps `Review transfer`, the screen validates the form and separately checks that a beneficiary was selected.

If all data is valid, it creates a `TransferDraft` and pushes the review screen using `extra`:

```dart
context.push(AppRoutes.transferReview, extra: draft);
```

The amount is converted from text to paise before the draft is created.

### 15.4 Review and confirm

`TransferReviewScreen` displays the draft and prevents double submission with `_processing`.

After a one-second fake bank request, it creates a `TransferReceipt` with a timestamp-based reference ID and navigates with:

```dart
context.go(AppRoutes.transferSuccess, extra: receipt);
```

The use of `go` intentionally removes the transfer and review screens from the back stack.

### 15.5 Show success

`TransferSuccessScreen` formats the receipt and provides a button that goes to the dashboard.

The screen explicitly says that balances do not update yet. That is not an accidental bug in this module; it is the boundary for the next state-management step.

## 16. Step Eleven: Understand the Riverpod Layer

The project already contains two providers:

- [`lib/features/accounts/state/account_provider.dart`](lib/features/accounts/state/account_provider.dart)
- [`lib/features/transactions/state/transactions_provider.dart`](lib/features/transactions/state/transactions_provider.dart)

### Accounts provider

`AccountsNotifier` owns a list of accounts and exposes `debit()`.

The debit algorithm is immutable:

1. Find the account by ID.
2. Reject an unknown account.
3. Reject zero, negative, or excessive amounts.
4. Create a new list.
5. Replace only the matching account with `copyWith`.
6. Assign the new list to `state`.

`accountByIdProvider` is derived state. It watches the account list and looks up one account by ID.

### Transactions provider

`TransactionsNotifier` owns the transaction list and can add a new transaction at the front.

`accountTransactionsProvider` is a family provider. It receives an account ID and returns only that account's transactions.

### Important current boundary

The providers are registered in the source tree and `ProviderScope` wraps the app, but the current presentation screens still read `MockData` directly. You can verify this by searching for `ref.watch` and `ref.read` in `lib/`.

That means a successful transfer currently creates a receipt but does not debit the account or add a transaction. Wiring the screens to these providers is the natural next exercise.

## 17. Step Twelve: Read the Tests

The tests are intentionally focused.

### Money tests

[`test/money_test.dart`](test/money_test.dart) checks:

- small values
- Indian digit grouping
- negative debits
- optional positive signs
- decimal parsing
- comma parsing
- invalid input

### Validator tests

[`test/validators_test.dart`](test/validators_test.dart) checks:

- required fields
- malformed values
- transfer limits
- insufficient funds
- valid amounts
- IFSC format
- matching account numbers
- beneficiary names
- login credentials

### Widget tests

[`test/widget_test.dart`](test/widget_test.dart) checks:

- the app starts on the login screen
- empty login fields display validation messages

Run all tests with:

```bash
flutter test
```

A useful next test would pump the transfer screen, add a beneficiary, and verify that the returned beneficiary becomes selected.

## 18. Suggested Teaching or Learning Sequence

Use one small concept at a time:

1. Run the existing app and inspect the login screen.
2. Read `main.dart` and `app.dart` to understand startup.
3. Read `theme.dart` and change the seed color.
4. Read the domain models before reading the widgets.
5. Read `money.dart` and its tests together.
6. Read `MockData` and identify which screens consume each collection.
7. Read the dashboard shell and understand `NavigationBar` plus `IndexedStack`.
8. Read `HomeTab`, then `BalanceCard`, then `QuickActions`.
9. Read the route constants and route tree.
10. Trace login from validation to `context.go`.
11. Trace transfer from query parameter to draft to receipt.
12. Read the Riverpod providers and compare them with the current `MockData` reads.
13. Run the tests and add one test for the next behavior you change.

## 19. Manual Demo Script

Use this script to demonstrate the complete application:

1. Launch the app and show the login screen.
2. Tap `Log in` with both fields empty and show the validation messages.
3. Enter customer ID `10012345` and PIN `1111`; show the invalid-login snackbar.
4. Enter PIN `1234`; explain that `go` replaces the login route.
5. On Home, tap the balance eye icon and explain local state.
6. Tap `View all` and scroll the generated statement.
7. Open Accounts, choose an account, and open its details.
8. Tap Transfer and show that the selected account came from a query parameter.
9. Tap Add new beneficiary.
10. Submit invalid beneficiary data to demonstrate validation.
11. Correct the data and save; explain `push<Beneficiary>` plus `pop(result)`.
12. Enter `500.50` and a short remark.
13. Open Review, edit the details, then review again.
14. Confirm the transfer and explain why success uses `go`.
15. Return to the dashboard and point out that the balance remains unchanged by design.
16. Open Profile, log out, confirm the dialog, and explain the final `go`.

## 20. Verification Checklist

Run these commands from the project directory:

```bash
flutter pub get
flutter analyze
flutter test
```

Expected result:

```text
flutter analyze: No issues found!
flutter test: All tests passed
```

For an iOS simulator:

```bash
flutter devices
flutter run -d "iPhone 16e"
```

If iOS reports `resource fork, Finder information, or similar detritus not allowed`, move the project out of `Desktop`, iCloud Drive, Dropbox, or another file-provider location and run `flutter clean` before rebuilding.

## 21. Troubleshooting

### Package imports cannot be resolved

Run:

```bash
flutter pub get
```

Also confirm that the package name in `pubspec.yaml` is `bankease`, because imports use `package:bankease/...`.

### No device is available

Run:

```bash
flutter devices
flutter emulators
```

Start an emulator, or open an iOS simulator from Xcode.

### The default Flutter widget test fails

The default test expects a `MyApp` widget. This project uses `BankEaseApp`, so use the tests in this repository instead of the generated default test.

### A route shows an error screen

Check the route data:

- account and statement routes require a valid account ID
- transfer review requires a `TransferDraft` in `extra`
- transfer success requires a `TransferReceipt` in `extra`

### A list produces an unbounded-height error

If a scrollable widget is inside a `Column`, give it a bounded height with `Expanded`. See `StatementScreen`.

### Validation misses fields

Use `SingleChildScrollView` with a `Column` for forms. Keep the fields in the same form and give the form a `GlobalKey<FormState>`.

### Transfer data does not persist

That is expected in the current module. Screens read mock data directly, and the transfer beneficiary list is local to `TransferScreen`. Connect the UI to the existing Riverpod providers in the next module.

## 22. Next Development Milestones

The project is ready for these follow-up exercises:

1. Convert `LoginScreen` to use an authentication provider.
2. Replace `MockData` reads with `accountProvider` and `transactionsProvider`.
3. Call `AccountsNotifier.debit` when a transfer is confirmed.
4. Add a debit transaction through `TransactionsNotifier.add`.
5. Move beneficiaries into a shared provider.
6. Add a repository layer under each feature's `data/` directory.
7. Replace mock data with an HTTP API.
8. Add loading, retry, and network-error states.
9. Add secure token storage and protected routes.
10. Add integration tests for login, transfer, logout, and back-stack behavior.

The central lesson of BankEase is the progression from a working UI to a maintainable application: start with plain models and deterministic mock data, isolate shared rules, make navigation data explicit, test the pure logic, and then replace each temporary boundary with real state and services.

## 23. Deeper Concepts Behind the Code

This section explains what Flutter is doing underneath the widgets so that the project is easier to modify safely.

### 23.1 Widget, element, and state

Every Flutter screen is a widget description. Flutter compares that description with the previous one and updates the rendered element tree only where something changed.

For example, `BalanceCard` is a `StatefulWidget`, while its `_BalanceCardState` owns `_hidden`:

```text
BalanceCard widget
  |
  v
_BalanceCardState
  |
  +-- _hidden = true
  +-- setState(() => _hidden = !_hidden)
```

The important distinction is:

- The widget receives configuration, such as the `Account` and optional `onTap` callback.
- The state object owns information that changes while this particular card is alive.
- `setState` tells Flutter that the state changed and that `build` should run again.
- `build` should describe the UI from the current values; it should not perform a network request or mutate unrelated state.

`DashboardScreen` uses the same idea for `_index`. That state belongs to the dashboard shell because the selected navigation destination is a property of the shell, not of an individual tab.

### 23.2 Why some widgets are stateless

`HomeTab`, `AccountsTab`, and `StatementScreen` are `StatelessWidget`s because their current output can be calculated from their inputs and the current mock data. They do not own a text controller, selection, loading flag, or other changing value.

A useful decision rule is:

```text
Does this widget own changing interaction data?
  no  -> StatelessWidget
  yes -> StatefulWidget or a provider-backed ConsumerWidget
```

The rule is about ownership, not screen size. A small balance card can need state, while a large statement screen can remain stateless.

### 23.3 The Flutter build and layout pipeline

When a screen is displayed, Flutter roughly performs these stages:

1. **Build:** widgets return child widgets.
2. **Layout:** parents pass constraints to children; children choose sizes within those constraints.
3. **Paint:** Flutter draws backgrounds, text, icons, and effects.
4. **Hit testing:** Flutter determines which widget receives a tap.

Most layout errors in this project come from misunderstanding constraints. A parent does not simply ask a child how large it wants to be; it gives the child a range of legal sizes.

This explains the two important list patterns in BankEase:

```text
ListView
  +-- fixed-size or intrinsic children
  +-- GridView(shrinkWrap: true, never scrolls)
```

and:

```text
Column
  +-- summary header
  +-- Expanded
  +-- ListView.separated
```

The outer `ListView` owns the page scroll. The inner quick-action grid reports its content height. In `StatementScreen`, `Expanded` gives the transaction list the remaining height of the screen.

If both the outer page and the inner list try to scroll, gesture ownership becomes confusing. If a list is placed in a `Column` without `Expanded`, the list receives an unbounded height and Flutter reports a viewport error.

### 23.4 `const` and rebuild cost

BankEase uses `const` for widgets whose configuration never changes during that build, for example:

```dart
const HomeTab()
const PaymentsTab()
const SizedBox(height: 16)
```

`const` allows Dart and Flutter to reuse identical widget descriptions. It does not make the entire screen immutable, and it does not prevent a child from responding to its own state.

Use `const` when the constructor arguments are compile-time constants. Do not force it when a value comes from `MockData`, route parameters, or user interaction.

### 23.5 How a route value travels through the app

The transfer-from-account example has a complete data path:

```text
AccountDetailScreen
  context.push('/dashboard/transfer?from=BE2001')
  |
  v
GoRouter parses state.uri.queryParameters['from']
  |
  v
TransferScreen(fromAccountId: 'BE2001')
  |
  v
initState validates the ID and sets _fromId
  |
  v
build selects the matching account and displays its balance
```

Each transport mechanism has a different job:

| Mechanism | Best for | Example |
|---|---|---|
| Path parameter | Resource identity in a URL | `/account/:id` |
| Query parameter | Optional screen configuration | `?from=BE2001` |
| `extra` | Typed in-memory objects | `TransferDraft` |
| `pop(result)` | Returning a value to the previous screen | `Beneficiary` |

Do not put a large mutable object into a path string. Do not assume `extra` survives a browser refresh. Do not use a global variable when a result can be returned directly to the screen that requested it.

### 23.6 The transfer screen as a state machine

The transfer flow is easier to reason about as states and events rather than as a collection of buttons:

| State | User event | Result |
|---|---|---|
| Editing | Select account | `_fromId` changes |
| Editing | Select beneficiary | `_selected` changes |
| Editing | Add beneficiary | Child form opens |
| Adding beneficiary | Save valid form | `Beneficiary` returns with `pop` |
| Editing | Review with invalid data | Form errors remain visible |
| Editing | Review with valid data | `TransferDraft` is pushed |
| Reviewing | Edit details | Review route is popped |
| Reviewing | Confirm | Loading indicator, then receipt |
| Completed | Back to dashboard | Dashboard route replaces flow |

This table suggests which variables belong where:

- `_fromId`, `_selected`, and `_showPayeeError` belong to the editing screen.
- `_processing` belongs to the review screen.
- `TransferDraft` belongs to the domain layer because both editing and review need it.
- `TransferReceipt` belongs to the domain layer because success displays the result.

When adding a new transfer behavior, first decide which state owns it. That prevents a review-only flag from leaking into the dashboard or a domain object from depending on Flutter widgets.

### 23.7 Why `mounted` matters after `await`

Both login and transfer confirmation wait asynchronously:

```dart
await Future<void>.delayed(...);
if (!mounted) return;
setState(...);
```

While the delay is running, the user could press Back or another route could replace the screen. The `State` object would then be disposed. Calling `setState` after disposal is invalid because there is no longer a live element to rebuild.

The safe sequence is:

1. Start the asynchronous operation.
2. Await it.
3. Check `mounted`.
4. Only then call `setState`, show a snackbar, or use the screen context.

The same principle appears after `context.push<Beneficiary>`. The transfer screen checks both `mounted` and whether the result is non-null.

### 23.8 The difference between local state and app state

The balance visibility toggle is local UI state. It belongs to one card and should disappear when that card is removed.

An account balance is app state. Multiple screens may need to see the same updated value after a debit. That state should not be copied independently into every screen.

The intended migration is:

```text
Current:
screens -> MockData.accounts

Next:
screens -> accountProvider -> AccountsNotifier -> repository/API
```

The same distinction applies to beneficiaries and transactions. If a beneficiary added on one screen must appear on another screen, it needs a shared owner rather than a local list inside `TransferScreen`.

### 23.9 How the Riverpod migration would work

The existing account provider can be consumed by a widget after converting the widget to a `ConsumerWidget`:

```dart
class AccountsTab extends ConsumerWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
  final account = accounts[index];
  return Text(account.maskedNumber);
      },
    );
  }
}
```

After a successful transfer, a controller could update both providers:

```dart
final debited = ref
    .read(accountProvider.notifier)
    .debit(draft.from.id, draft.amountPaise);

if (debited) {
  ref.read(transactionsProvider.notifier).add(newTransaction);
}
```

That example is intentionally incomplete: a production transfer must also handle server confirmation, failures, idempotency, and concurrency. Its purpose is to show the dependency direction. Widgets trigger intent; providers own state transitions; repositories perform I/O.

### 23.10 Why immutable updates are used

The provider does not mutate an account in place. It creates a new list and a new account:

```text
old state: [account A, account B]
         |
         v
new state: [new A with lower balance, account B]
```

This gives Riverpod a new state value to publish and makes the change easier to test. It also avoids hidden side effects where one screen still holds a reference to an object that another screen silently changed.

### 23.11 Testing strategy for this project

The current tests follow a useful testing pyramid:

```text
many small pure-function tests
  |
  +-- money parsing and formatting
  +-- validation rules
  v
fewer widget tests
  |
  +-- initial screen
  +-- visible validation behavior
  v
future integration tests
  |
  +-- login -> dashboard
  +-- transfer -> review -> receipt
  +-- logout and back-stack behavior
```

Start with pure functions because they are fast and deterministic. Add widget tests when behavior depends on Flutter interaction. Add integration tests when several routes, providers, or platform services must work together.

For every new feature, ask three questions:

1. What rule can be tested without Flutter?
2. What visible interaction needs a widget test?
3. What complete user journey needs an integration test?

This keeps the test suite focused instead of trying to test every private implementation detail.
