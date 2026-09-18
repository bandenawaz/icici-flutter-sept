import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/widgets/route_error_screen.dart';
import 'package:bankease/features/accounts/presentation/account_detail_screen.dart';
import 'package:bankease/features/auth/presentation/login_screen.dart';
import 'package:bankease/features/dashboard/presentation/dashboard_screen.dart';
import 'package:bankease/features/transactions/presentation/statement_screen.dart';
import 'package:bankease/features/transfer/domain/transfer_draft.dart';
import 'package:bankease/features/transfer/presentation/add_beneficiary_screen.dart';
import 'package:bankease/features/transfer/presentation/transfer_review_screen.dart';
import 'package:bankease/features/transfer/presentation/transfer_screen.dart';
import 'package:bankease/features/transfer/presentation/transfer_success_screen.dart';

/// URL map
///   /login
///   /dashboard
///   /dashboard/account/:id
///   /dashboard/statement/:accountId
///   /dashboard/transfer?from=BE2001
///   /dashboard/transfer/review          (extra: TransferDraft)
///   /dashboard/transfer-success         (extra: TransferReceipt)
///   /dashboard/beneficiaries/add        (returns: Beneficiary)
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: true,
  errorBuilder: (context, state) =>
      RouteErrorScreen(message: 'No page found for ${state.uri}'),
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
      // Child paths have no leading slash; they are added to the parent path.
      routes: [
        GoRoute(
          path: 'account/:id',
          builder: (context, state) =>
              AccountDetailScreen(accountId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'statement/:accountId',
          builder: (context, state) =>
              StatementScreen(accountId: state.pathParameters['accountId']!),
        ),
        GoRoute(
          path: 'transfer',
          builder: (context, state) => TransferScreen(
            fromAccountId: state.uri.queryParameters['from'],
          ),
          routes: [
            GoRoute(
              path: 'review',
              builder: (context, state) {
                final extra = state.extra;
                // extra is lost on deep links / web refresh, so always check it.
                if (extra is! TransferDraft) {
                  return const RouteErrorScreen(
                    message: 'Transfer details are missing. Please start again.',
                  );
                }
                return TransferReviewScreen(draft: extra);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'transfer-success',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is! TransferReceipt) {
              return const RouteErrorScreen(message: 'No transfer to show.');
            }
            return TransferSuccessScreen(receipt: extra);
          },
        ),
        GoRoute(
          path: 'beneficiaries/add',
          builder: (context, state) => const AddBeneficiaryScreen(),
        ),
      ],
    ),
  ],
);
