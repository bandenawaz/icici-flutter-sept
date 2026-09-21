'use strict';

const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const { ApiError, serverError } = require('./src/errors');
const { requireAuth } = require('./src/auth');
const authRoutes = require('./src/routes/auth');
const accountRoutes = require('./src/routes/accounts');
const beneficiaryRoutes = require('./src/routes/beneficiaries');
const transferRoutes = require('./src/routes/transfers');
const { router: devRoutes, chaos } = require('./src/routes/dev');

const app = express();
const PORT = Number(process.env.PORT || 4000);
const BASE = '/api/v1';

app.use(cors()); // the Flutter web build calls this API from a browser
app.use(express.json());

// Simple request log: method, path, status, duration.
app.use((req, res, next) => {
  const started = Date.now();
  res.on('finish', () => {
    console.log(`${req.method} ${req.originalUrl} → ${res.statusCode} (${Date.now() - started} ms)`);
  });
  next();
});

// Teaching middleware: slow responses, random failures, or a full outage.
app.use(async (req, res, next) => {
  if (req.path.startsWith(`${BASE}/dev`)) return next();
  if (chaos.down) return next(new ApiError(503, 'SERVICE_UNAVAILABLE', 'Service temporarily unavailable'));
  if (chaos.delayMs > 0) await new Promise((r) => setTimeout(r, chaos.delayMs));
  if (chaos.failRate > 0 && Math.random() < chaos.failRate) return next(serverError());
  next();
});

app.get(`${BASE}/ping`, (req, res) => res.json({ ok: true, time: new Date().toISOString() }));

app.use(`${BASE}/auth`, authRoutes);
app.use(`${BASE}/dev`, devRoutes);

// Everything below needs a valid token.
app.use(`${BASE}/accounts`, requireAuth, accountRoutes);
app.use(`${BASE}/beneficiaries`, requireAuth, beneficiaryRoutes);
app.use(`${BASE}/transfers`, requireAuth, transferRoutes);

// Unknown URL
app.use((req, res, next) => next(new ApiError(404, 'NOT_FOUND', `No endpoint for ${req.method} ${req.path}`)));

// One error shape for the whole API, so the app can parse failures reliably.
app.use((err, req, res, next) => { // eslint-disable-line no-unused-vars
  const apiError = err instanceof ApiError ? err : serverError();
  if (!(err instanceof ApiError)) console.error(err);
  res.status(apiError.status).json({
    error: {
      code: apiError.code,
      message: apiError.message,
      details: apiError.details,
      traceId: crypto.randomUUID(),
    },
  });
});

app.listen(PORT, () => {
  console.log(`BankEase API listening on http://localhost:${PORT}${BASE}`);
  console.log('Demo login: customerId 10012345, pin 1234');
  console.log('Android emulator uses http://10.0.2.2:' + PORT);
});
