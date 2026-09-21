/// Every path in the app, in one place.
/// Screens call these helpers instead of typing strings by hand.
abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';

  static String account(String id) => '/dashboard/account/$id';
  static String statement(String accountId) => '/dashboard/statement/$accountId';

  static String transfer({String? fromAccountId}) => fromAccountId == null
      ? '/dashboard/transfer'
      : '/dashboard/transfer?from=$fromAccountId';

  static const transferReview = '/dashboard/transfer/review';
  static const transferSuccess = '/dashboard/transfer-success';
  static const addBeneficiary = '/dashboard/beneficiaries/add';
}
