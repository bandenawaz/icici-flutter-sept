'use strict';

/**
 * Every failure in this API is an ApiError.
 * The HTTP status says WHAT KIND of problem it is;
 * the code says exactly WHICH problem, so the app can react.
 */
class ApiError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

const badRequest = (msg, details) => new ApiError(400, 'BAD_REQUEST', msg, details);
const unauthorized = (msg = 'Please log in again') => new ApiError(401, 'UNAUTHORIZED', msg);
const forbidden = (msg = 'Not allowed') => new ApiError(403, 'FORBIDDEN', msg);
const notFound = (msg = 'Not found') => new ApiError(404, 'NOT_FOUND', msg);
const conflict = (code, msg) => new ApiError(409, code, msg);
const unprocessable = (code, msg, details) => new ApiError(422, code, msg, details);
const serverError = (msg = 'Something went wrong on our side') =>
  new ApiError(500, 'SERVER_ERROR', msg);

module.exports = {
  ApiError, badRequest, unauthorized, forbidden, notFound,
  conflict, unprocessable, serverError,
};
