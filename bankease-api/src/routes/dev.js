'use strict';

/**
 * Teaching endpoints. They let the trainer break the API on purpose,
 * so learners can see loading, error and retry states.
 * A real bank would never ship this router.
 */
const express = require('express');
const auth = require('../auth');

const router = express.Router();

const chaos = { delayMs: 0, failRate: 0, down: false };

// GET /api/v1/dev/chaos?delayMs=2000&failRate=0.5&down=true
router.get('/chaos', (req, res) => {
  if (req.query.delayMs !== undefined) chaos.delayMs = Math.max(0, Number(req.query.delayMs) || 0);
  if (req.query.failRate !== undefined) {
    chaos.failRate = Math.min(1, Math.max(0, Number(req.query.failRate) || 0));
  }
  if (req.query.down !== undefined) chaos.down = req.query.down === 'true';
  res.json({ ...chaos, hint: 'Call /api/v1/dev/chaos/reset to go back to normal' });
});

router.get('/chaos/reset', (req, res) => {
  chaos.delayMs = 0;
  chaos.failRate = 0;
  chaos.down = false;
  res.json({ ...chaos });
});

// GET /api/v1/dev/expire-token  → every issued token becomes invalid
router.get('/expire-token', (req, res) => {
  auth.expireAllTokens();
  res.json({ expired: true, hint: 'The next protected call returns 401' });
});

module.exports = { router, chaos };
