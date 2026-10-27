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
  const { scenario, canManage, withRole, clearScenario } = useReviewParams();
  const invoices = useMockInvoices();
  const [confirmOpen, setConfirmOpen] = useState(false);

  const back = <Link to={withRole('/invoices')}>← Back</Link>;
  const invoice = scenario === 'empty' ? undefined : invoices.find((i) => i.id === id);

  if (scenario === 'loading') return <PageLoader />;
  if (scenario === 'error') {
    return <ErrorState title="Invoice could not be loaded" action={<Button onClick={clearScenario}>Try again</Button>} />;
  }
  if (!invoice) {
    return <EmptyState title="This invoice does not exist" action={back} />;
  }

  const handleDelete = () => {
    deleteInvoice(invoice.id);
    navigate(withRole('/invoices'));
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
                onChange={(e) => updateInvoiceStatus(invoice.id, e.target.value as MockInvoiceStatus)}
                options={invoiceStatusOptions}
              />
            )}
          </div>
        </Field>
      </Card>
      <Modal
        title={`Delete ${invoice.number}?`}
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        footer={
          <>
            <Button onClick={() => setConfirmOpen(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleDelete}>Delete invoice</Button>
          </>
        }
      >
        <p className={styles.confirmText}>The invoice for {invoice.customerName} is removed for everyone. This cannot be undone.</p>
      </Modal>
    </div>
  );
}
