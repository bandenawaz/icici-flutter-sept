'use strict';

const express = require('express');
const crypto = require('crypto');
const db = require('../db');
const { badRequest, conflict, unprocessable, notFound, forbidden } = require('../errors');

const router = express.Router();

const MAX_TRANSFER_PAISE = 10000000; // ₹1,00,000 per transfer

// POST /api/v1/transfers
// Headers: Authorization, Idempotency-Key
// Body: { fromAccountId, beneficiaryId, amountPaise, remarks? }
router.post('/', (req, res) => {
  const key = req.get('idempotency-key');
  if (!key) throw badRequest('Idempotency-Key header is required');

  const { fromAccountId, beneficiaryId, amountPaise, remarks } = req.body || {};

  // 1. Idempotency: have we already processed this exact key?
  const previous = db.receiptsByKey.get(key);
  if (previous) {
    const samePayload =
      previous.request.fromAccountId === fromAccountId &&
      previous.request.beneficiaryId === beneficiaryId &&
      previous.request.amountPaise === amountPaise;
    if (!samePayload) {
      throw conflict('IDEMPOTENCY_KEY_REUSED', 'This key was used for a different transfer');
    }
    // Replay: return the same receipt, and do NOT move money again.
    return res.status(200).json(previous.receipt);
  }

  // 2. Validate
  const errors = {};
  if (!fromAccountId) errors.fromAccountId = 'Required';
  if (!beneficiaryId) errors.beneficiaryId = 'Required';
  if (!Number.isInteger(amountPaise)) errors.amountPaise = 'Must be a whole number of paise';
  if (Object.keys(errors).length > 0) throw badRequest('Please check the details', errors);

  const account = db.findAccount(fromAccountId);
  if (!account) throw notFound('Account not found');
  if (account.customerId !== req.customerId) throw forbidden('This is not your account');

  const beneficiary = db
    .beneficiariesOf(req.customerId)
    .find((b) => b.id === beneficiaryId);
  if (!beneficiary) throw notFound('Beneficiary not found');

  // 3. Business rules. The app checked these too, for a fast message.
  //    The server checks them again, because only the server can be trusted.
  if (amountPaise <= 0) {
    throw unprocessable('INVALID_AMOUNT', 'Amount must be more than ₹0');
  }
  if (amountPaise > MAX_TRANSFER_PAISE) {
    throw unprocessable('LIMIT_EXCEEDED', 'Maximum per transfer is ₹1,00,000');
  }
  if (amountPaise > account.balancePaise) {
    throw unprocessable('INSUFFICIENT_FUNDS', 'Insufficient funds', {
      shortByPaise: amountPaise - account.balancePaise,
    });
  }

  // 4. Move the money and record it. In a real bank this is one database
  //    transaction: both steps happen, or neither does.
  account.balancePaise -= amountPaise;
  const now = new Date().toISOString();
  const referenceId = `BE${Date.now()}${crypto.randomUUID().slice(0, 4)}`;

  const txn = db.addTransaction({
    id: referenceId,
    accountId: account.id,
    title: `To ${beneficiary.name}`,
    amountPaise: -amountPaise,
    mode: 'IMPS',
    at: now,
  });

  const receipt = {
    referenceId,
    fromAccountId: account.id,
    beneficiaryId: beneficiary.id,
    beneficiaryName: beneficiary.name,
    amountPaise,
    remarks: remarks ? String(remarks).slice(0, 30) : '',
    balanceAfterPaise: account.balancePaise,
    completedAt: now,
    transaction: txn,
  };

  db.receiptsByKey.set(key, {
    request: { fromAccountId, beneficiaryId, amountPaise },
    receipt,
  });

  res.status(201).json(receipt);
});

module.exports = router;
