export interface FinancialRequestContext {
  readonly idempotencyKey?: string;
  readonly requestHash?: string;
  readonly requestId?: string;
  readonly ipAddress?: string;
}
