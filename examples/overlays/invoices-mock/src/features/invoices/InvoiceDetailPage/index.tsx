import { useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router';
import { Button, Card, EmptyState, ErrorState, Field, Modal, PageHeader, PageLoader } from '../../../shared/components';
import { formatTotal } from '../formatTotal';
import { InvoiceStatusBadge } from '../InvoiceStatusBadge';
import { invoiceStatusOptions, type MockInvoiceStatus } from '../mockData';
import { deleteInvoice, updateInvoiceStatus, useMockInvoices } from '../mockStore';
import { useReviewParams } from '../reviewParams';
import { SelectField } from '../SelectField';
import styles from './InvoiceDetailPage.module.css';

export function InvoiceDetailPage() {
  const { id = '' } = useParams();
  const navigate = useNavigate();
  const { scenario, writeFails, canManage, withRole, clearScenario } = useReviewParams();
  const invoices = useMockInvoices();
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [failure, setFailure] = useState<'status' | 'delete' | null>(null);

  const back = <Link to={withRole('/invoices')}>← Back</Link>;
  const invoice = scenario === 'empty' ? undefined : invoices.find((i) => i.id === id);

  if (scenario === 'loading') return <PageLoader />;
  if (scenario === 'error') {
    return <ErrorState title="Invoice could not be loaded" action={<Button onClick={clearScenario}>Try again</Button>} />;
  }
  if (!invoice) {
    return <EmptyState title="This invoice does not exist" action={back} />;
  }

  const runWrite = async (kind: 'status' | 'delete', write: () => Promise<void>) => {
    setBusy(true);
    setFailure(null);
    try {
      await write();
      return true;
    } catch {
      setFailure(kind);
      return false;
    } finally {
      setBusy(false);
    }
  };
  const handleDelete = async () => {
    if (await runWrite('delete', () => deleteInvoice(invoice.id, writeFails))) navigate(withRole('/invoices'));
  };
  const handleStatusChange = (status: MockInvoiceStatus) => {
    void runWrite('status', () => updateInvoiceStatus(invoice.id, status, writeFails));
  };

  return (
    <div className={styles.page}>
      <PageHeader
        back={back}
        title={invoice.number}
        subtitle={invoice.customerName}
        actions={canManage && <Button variant="danger" onClick={() => setConfirmOpen(true)}>Delete invoice</Button>}
      />
      <Card>
        <Field label="Customer">{invoice.customerName}</Field>
        <Field label="Total">{formatTotal(invoice.total, invoice.currency)}</Field>
        <Field label="Due date">{invoice.dueDate}</Field>
        <Field label="Status">
          <div className={styles.status}>
            <InvoiceStatusBadge status={invoice.status} />
            {canManage && (
              <SelectField
                label="Change status"
                value={invoice.status}
                disabled={busy}
                onChange={(e) => handleStatusChange(e.target.value as MockInvoiceStatus)}
                options={invoiceStatusOptions}
              />
            )}
          </div>
          {failure === 'status' && <p className={styles.error} role="alert">The status could not be changed. Try again.</p>}
        </Field>
      </Card>
      <Modal
        title={`Delete ${invoice.number}?`}
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        footer={
          <>
            <Button onClick={() => setConfirmOpen(false)} disabled={busy}>Cancel</Button>
            <Button variant="danger" onClick={handleDelete} disabled={busy}>
              {busy ? 'Deleting…' : 'Delete invoice'}
            </Button>
          </>
        }
      >
        <p className={styles.confirmText}>The invoice for {invoice.customerName} is removed for everyone. This cannot be undone.</p>
        {failure === 'delete' && <p className={styles.error} role="alert">The invoice could not be deleted. Try again.</p>}
      </Modal>
    </div>
  );
}
