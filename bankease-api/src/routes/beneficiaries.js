'use strict';

const express = require('express');
const crypto = require('crypto');
const db = require('../db');
const { badRequest, conflict, notFound } = require('../errors');

const router = express.Router();

const IFSC = /^[A-Z]{4}0[A-Z0-9]{6}$/;
const ACCOUNT_NUMBER = /^\d{9,18}$/;

const toJson = (b) => ({
  id: b.id, name: b.name, accountNumber: b.accountNumber, ifsc: b.ifsc,
});

// GET /api/v1/beneficiaries
router.get('/', (req, res) => {
  res.json({ items: db.beneficiariesOf(req.customerId).map(toJson) });
});

// POST /api/v1/beneficiaries  { name, accountNumber, ifsc }
router.post('/', (req, res) => {
  const { name, accountNumber, ifsc } = req.body || {};
  const errors = {};

  if (!name || String(name).trim().length < 3) errors.name = 'Name must be at least 3 characters';
  if (!ACCOUNT_NUMBER.test(String(accountNumber || ''))) {
    errors.accountNumber = 'Account number must be 9 to 18 digits';
  }
  if (!IFSC.test(String(ifsc || '').toUpperCase())) {
    errors.ifsc = 'IFSC must be 4 letters, 0, then 6 letters or digits';
  }
  // The server repeats every check the app made. The app can be modified;
  // the server cannot.
  if (Object.keys(errors).length > 0) throw badRequest('Please check the details', errors);

  const duplicate = db
    .beneficiariesOf(req.customerId)
    .some((b) => b.accountNumber === String(accountNumber));
  if (duplicate) throw conflict('BENEFICIARY_EXISTS', 'This account is already saved');

  const beneficiary = {
    id: `B${crypto.randomUUID().slice(0, 8)}`,
    customerId: req.customerId,
    name: String(name).trim(),
    accountNumber: String(accountNumber),
    ifsc: String(ifsc).toUpperCase(),
  };
  db.addBeneficiary(beneficiary);
  res.status(201).json(toJson(beneficiary));
});

// DELETE /api/v1/beneficiaries/:id
router.delete('/:id', (req, res) => {
  const removed = db.removeBeneficiary(req.customerId, req.params.id);
  if (!removed) throw notFound('Beneficiary not found');
  res.status(204).end();
});

module.exports = router;
