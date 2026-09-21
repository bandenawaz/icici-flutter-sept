'use strict';

const express = require('express');
const auth = require('../auth');

const router = express.Router();

// POST /api/v1/auth/login  { customerId, pin }
router.post('/login', (req, res) => {
  const { customerId, pin } = req.body || {};
  res.json(auth.login(customerId, pin));
});

// POST /api/v1/auth/logout  (Bearer token)
router.post('/logout', auth.requireAuth, (req, res) => {
  auth.revokeToken(req.token);
  res.status(204).end();
});

module.exports = router;
