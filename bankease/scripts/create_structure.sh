#!/usr/bin/env bash
# Run from inside the bankease project folder (macOS / Linux / Git Bash).
set -e
mkdir -p lib/app
mkdir -p lib/core/data lib/core/utils lib/core/widgets
mkdir -p lib/features/auth/presentation
mkdir -p lib/features/accounts/domain lib/features/accounts/presentation
mkdir -p lib/features/dashboard/presentation lib/features/dashboard/widgets
mkdir -p lib/features/transactions/domain lib/features/transactions/presentation lib/features/transactions/widgets
mkdir -p lib/features/transfer/domain lib/features/transfer/presentation
mkdir -p lib/features/payments/presentation
mkdir -p lib/features/profile/presentation
echo "BankEase folders created."
