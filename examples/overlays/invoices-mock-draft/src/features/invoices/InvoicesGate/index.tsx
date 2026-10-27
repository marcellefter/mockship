import type { ReactNode } from 'react';
import { useFlag } from '../../../flags';
import { NotFoundPage } from '../../../pages/NotFoundPage';

// Flags are synchronous in this app, so there is no loading branch.
export function InvoicesGate({ children }: { children: ReactNode }) {
  const enabled = useFlag('invoices-beta');
  if (!enabled) return <NotFoundPage />;
  return <>{children}</>;
}
