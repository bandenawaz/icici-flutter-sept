'use strict';

/**
 * In-memory "database".
 * Everything resets when the server restarts, which is exactly what a
 * classroom wants. Money is always an integer number of paise.
 */

const customers = [
  { id: '10012345', name: 'Asha Rao', pin: '1234' },
  { id: '10067890', name: 'Ravi Kumar', pin: '1234' },
];

const accounts = [
  {
    id: 'BE1001', customerId: '10012345', type: 'SAVINGS', holderName: 'Asha Rao',
    number: '501000123451001', ifsc: 'BKEN0001234', branch: 'Bijapur Main',
    balancePaise: 498050,
  },
  {
    id: 'BE2001', customerId: '10012345', type: 'CURRENT', holderName: 'Asha Rao',
    number: '502000987652001', ifsc: 'BKEN0001234', branch: 'Bijapur Main',
    balancePaise: 12500000,
  },
  {
    id: 'BE3001', customerId: '10067890', type: 'SAVINGS', holderName: 'Ravi Kumar',
    number: '501000555553001', ifsc: 'BKEN0001234', branch: 'Bijapur Main',
    balancePaise: 250000,
  },
];

const beneficiaries = [
  { id: 'B1', customerId: '10012345', name: 'Ravi Kumar', accountNumber: '123456789012', ifsc: 'NOVA0004567' },
  { id: 'B2', customerId: '10012345', name: 'Meera Traders', accountNumber: '987654321098', ifsc: 'TRUB0001122' },
  { id: 'B3', customerId: '10012345', name: 'Suresh Patil', accountNumber: '456789123456', ifsc: 'BKEN0003344' },
];

const transactions = [];

/** Deterministic seed data, newest first, so the statement looks real. */
function seedTransactions() {
  const samples = [
    ['Chai stall', -2000, 'UPI'],
    ['Salary credit', 6500000, 'NEFT'],
    ['Electricity bill', -184500, 'UPI'],
    ['Food delivery order', -45600, 'UPI'],
    ['Mobile recharge', -29900, 'UPI'],
    ['ATM withdrawal', -500000, 'ATM'],
    ['Interest credit', 23400, 'NEFT'],
    ['Online shopping - Venkata Satya Narayana Enterprises', -129900, 'UPI'],
  ];
  const start = Date.parse('2026-09-15T18:30:00.000Z');
  for (let i = 0; i < 240; i++) {
    const [title, amountPaise, mode] = samples[i % samples.length];
    transactions.push({
      id: `T${10000 + i}`,
      accountId: i % 3 === 0 ? 'BE2001' : 'BE1001',
      title,
      amountPaise,
      mode,
      at: new Date(start - i * 7 * 3600 * 1000).toISOString(),
    });
  }
  transactions.push({
    id: 'T20000', accountId: 'BE3001', title: 'Opening deposit',
    amountPaise: 250000, mode: 'NEFT', at: new Date(start).toISOString(),
  });
}
seedTransactions();

/** Every processed transfer, keyed by its Idempotency-Key. */
const receiptsByKey = new Map();

const findCustomer = (id) => customers.find((c) => c.id === id);
const accountsOf = (customerId) => accounts.filter((a) => a.customerId === customerId);
const findAccount = (id) => accounts.find((a) => a.id === id);
const beneficiariesOf = (customerId) => beneficiaries.filter((b) => b.customerId === customerId);
const transactionsOf = (accountId) =>
  transactions
    .filter((t) => t.accountId === accountId)
    .sort((a, b) => Date.parse(b.at) - Date.parse(a.at));

function addTransaction(txn) {
  transactions.push(txn);
  return txn;
}

function addBeneficiary(b) {
  beneficiaries.push(b);
  return b;
}

function removeBeneficiary(customerId, id) {
  const i = beneficiaries.findIndex((b) => b.id === id && b.customerId === customerId);
  if (i === -1) return false;
  beneficiaries.splice(i, 1);
  return true;
}

module.exports = {
  customers, accounts, beneficiaries, transactions, receiptsByKey,
  findCustomer, accountsOf, findAccount, beneficiariesOf, transactionsOf,
  addTransaction, addBeneficiary, removeBeneficiary,
};
