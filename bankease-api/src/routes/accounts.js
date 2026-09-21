'use strict';

const express = require('express');
const db = require('../db');
const { notFound, forbidden } = require('../errors');

const router = express.Router();

const toJson = (a) => ({
  id: a.id,
  type: a.type,
  holderName: a.holderName,
  number: a.number,
  ifsc: a.ifsc,
  branch: a.branch,
  balancePaise: a.balancePaise,
});

// GET /api/v1/accounts
router.get('/', (req, res) => {
  res.json({ items: db.accountsOf(req.customerId).map(toJson) });
});

// GET /api/v1/accounts/:id
router.get('/:id', (req, res) => {
  const account = db.findAccount(req.params.id);
  if (!account) throw notFound(`Account ${req.params.id} was not found`);
  if (account.customerId !== req.customerId) throw forbidden('This is not your account');
  res.json(toJson(account));
});

// GET /api/v1/accounts/:id/transactions?page=0&size=20
router.get('/:id/transactions', (req, res) => {
  const account = db.findAccount(req.params.id);
  if (!account) throw notFound(`Account ${req.params.id} was not found`);
  if (account.customerId !== req.customerId) throw forbidden('This is not your account');

  const page = Math.max(0, Number(req.query.page) || 0);
  const size = Math.min(100, Math.max(1, Number(req.query.size) || 20));
  const all = db.transactionsOf(account.id);
  const start = page * size;
  const items = all.slice(start, start + size);

  res.json({
    items,
    page,
    size,
    total: all.length,
    hasMore: start + items.length < all.length,
  });
});

module.exports = router;
