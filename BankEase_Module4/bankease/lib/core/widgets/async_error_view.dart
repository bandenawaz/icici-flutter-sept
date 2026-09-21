import 'package:flutter/material.dart';

import 'package:bankease/core/errors/bank_error.dart';

/// One place that turns any error into a friendly screen with a Retry button.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Known errors carry a message written for users.
    // Anything else gets a safe generic message: never show a stack trace.
    final message = error is BankError
        ? (error as BankError).message
        : 'Something went wrong. Please try again.';
    final icon = error is NetworkError ? Icons.wifi_off : Icons.error_outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The loading state, used while a request is in flight.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
}
