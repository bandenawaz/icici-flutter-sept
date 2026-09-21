import 'package:bankease/core/utils/money.dart';

/// Every validator follows the Flutter contract:
///   return null      -> the value is valid
///   return 'message' -> the field shows this message in red
///
/// Client-side checks are for user experience only.
/// The bank's server re-checks everything (Module 4).
abstract final class Validators {
  static const int maxTransferPaise = 10000000; // ₹1,00,000

  static String? customerId(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your customer ID';
    if (!RegExp(r'^\d{8}$').hasMatch(v)) return 'Customer ID must be 8 digits';
    return null;
  }

  static String? pin(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter your PIN';
    if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'PIN must be 4 digits';
    return null;
  }

  static String? amount(
    String? value, {
    required int balancePaise,
    int maxPaise = maxTransferPaise,
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter an amount';
    final paise = parseRupeesToPaise(v);
    if (paise == null) return 'Enter a valid amount (up to 2 decimals)';
    if (paise <= 0) return 'Amount must be more than ₹0';
    if (paise > maxPaise) {
      return 'Maximum per transfer is ${formatRupees(maxPaise)}';
    }
    if (paise > balancePaise) return 'Insufficient funds';
    return null;
  }

  static String? remarks(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 30) return 'Keep remarks under 30 characters';
    if (!RegExp(r'^[A-Za-z0-9 .,\-]*$').hasMatch(v)) {
      return 'Use letters, numbers, spaces, dots, commas or hyphens';
    }
    return null;
  }

  static String? beneficiaryName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the beneficiary name';
    if (v.length < 3) return 'Name is too short';
    if (!RegExp(r"^[A-Za-z][A-Za-z .'\-]*$").hasMatch(v)) {
      return 'Use letters, spaces, dots or hyphens only';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the account number';
    if (!RegExp(r'^\d{9,18}$').hasMatch(v)) {
      return 'Account number must be 9 to 18 digits';
    }
    return null;
  }

  static String? confirmAccountNumber(String? value, String original) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Re-enter the account number';
    if (v != original.trim()) return 'Account numbers do not match';
    return null;
  }

  /// IFSC: 4 letters, the digit 0, then 6 letters or digits (e.g. BKEN0001234).
  static String? ifsc(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'Enter the IFSC code';
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v)) {
      return 'IFSC must be 4 letters, 0, then 6 letters or digits';
    }
    return null;
  }
}
