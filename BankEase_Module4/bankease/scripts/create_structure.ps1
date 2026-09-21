# Run from inside the bankease project folder (Windows PowerShell).
$folders = @(
  'lib/app',
  'lib/core/data', 'lib/core/utils', 'lib/core/widgets',
  'lib/features/auth/presentation',
  'lib/features/accounts/domain', 'lib/features/accounts/presentation',
  'lib/features/dashboard/presentation', 'lib/features/dashboard/widgets',
  'lib/features/transactions/domain', 'lib/features/transactions/presentation', 'lib/features/transactions/widgets',
  'lib/features/transfer/domain', 'lib/features/transfer/presentation',
  'lib/features/payments/presentation',
  'lib/features/profile/presentation'
)
foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f | Out-Null }
Write-Host 'BankEase folders created.'
