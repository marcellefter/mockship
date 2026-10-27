import { StatusBadge, type StatusTone } from '../../../shared/components';
import { invoiceStatusOptions, type MockInvoiceStatus } from '../mockData';
import styles from './InvoiceStatusBadge.module.css';

const tones: Record<Exclude<MockInvoiceStatus, 'on-hold'>, StatusTone> = {
  draft: 'neutral',
  sent: 'info',
  paid: 'success',
  overdue: 'danger',
};

// Shared StatusBadge has no purple tone, so "On hold" renders a local badge on the accent tokens.
export function InvoiceStatusBadge({ status }: { status: MockInvoiceStatus }) {
  const label = invoiceStatusOptions.find((o) => o.value === status)?.label ?? status;
  if (status === 'on-hold') return <span className={styles.onHold}>{label}</span>;
  return <StatusBadge tone={tones[status]} label={label} />;
}
