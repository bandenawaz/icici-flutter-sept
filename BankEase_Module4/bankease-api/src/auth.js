'use strict';

const crypto = require('crypto');
const db = require('./db');
const { unauthorized, badRequest } = require('./errors');

/** token -> { customerId, expiresAt } */
const tokens = new Map();

const TOKEN_TTL_MS = Number(process.env.TOKEN_TTL_MS || 30 * 60 * 1000); // 30 minutes

function issueToken(customerId) {
  const token = crypto.randomUUID();
  tokens.set(token, { customerId, expiresAt: Date.now() + TOKEN_TTL_MS });
  return { token, expiresInSeconds: Math.floor(TOKEN_TTL_MS / 1000) };
}

function revokeToken(token) {
  tokens.delete(token);
}

/** Used by the /dev/expire-token endpoint to demo 401 handling. */
function expireAllTokens() {
  for (const [token, value] of tokens) {
    tokens.set(token, { ...value, expiresAt: Date.now() - 1 });
  }
}

function login(customerId, pin) {
  if (!customerId || !pin) throw badRequest('customerId and pin are required');
  const customer = db.findCustomer(String(customerId));
  // Same message for a wrong ID and a wrong PIN: never tell an attacker
  // which customer IDs exist.
  if (!customer || customer.pin !== String(pin)) {
    throw unauthorized('Invalid customer ID or PIN');
  }
  const { token, expiresInSeconds } = issueToken(customer.id);
  return {
    token,
    expiresInSeconds,
    customer: { id: customer.id, name: customer.name },
  };
}

/** Express middleware: every protected route goes through this. */
function requireAuth(req, res, next) {
  const header = req.get('authorization') || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return next(unauthorized('Missing bearer token'));
  }
  const session = tokens.get(token);
  if (!session) return next(unauthorized('Invalid token'));
  if (session.expiresAt < Date.now()) {
    tokens.delete(token);
    return next(unauthorized('Session expired'));
  }
  req.token = token;
  req.customerId = session.customerId;
  next();
}

module.exports = { login, requireAuth, revokeToken, expireAllTokens, tokens };
