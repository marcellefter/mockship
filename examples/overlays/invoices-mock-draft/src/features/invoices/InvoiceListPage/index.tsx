import { useState } from 'react';
import { Link } from 'react-router';
import { Button, DataTable, EmptyState, ErrorState, PageHeader, PageLoader, type Column } from '../../../shared/components';
import { formatTotal } from '../formatTotal';
import { InvoiceStatusBadge } from '../InvoiceStatusBadge';
import { invoiceStatusOptions, type MockInvoice, type MockInvoiceStatus } from '../mockData';
import { createInvoice, useMockInvoices } from '../mockStore';
import { NewInvoiceModal } from '../NewInvoiceModal';
import { useReviewParams } from '../reviewParams';
import { SelectField } from '../SelectField';
import styles from './InvoiceListPage.module.css';

export function InvoiceListPage() {
  const { scenario, canManage, withRole, clearScenario } = useReviewParams();
  const invoices = useMockInvoices();
  const [statusFilter, setStatusFilter] = useState<MockInvoiceStatus | 'all'>('all');
  const [modalOpen, setModalOpen] = useState(false);

  const rows = scenario === 'empty' ? [] : invoices;
  const visibleRows = statusFilter === 'all' ? rows : rows.filter((i) => i.status === statusFilter);

  const columns: Column<MockInvoice>[] = [
    { key: 'number', header: 'Number', render: (i) => <Link to={withRole(`/invoices/${i.id}`)}>{i.number}</Link> },
    { key: 'customer', header: 'Customer', render: (i) => i.customerName },
    { key: 'total', header: 'Total', align: 'right', render: (i) => formatTotal(i.total, i.currency) },
    { key: 'status', header: 'Status', render: (i) => <InvoiceStatusBadge status={i.status} /> },
    { key: 'dueDate', header: 'Due date', render: (i) => i.dueDate },
  ];

  const newInvoiceButton = canManage && (
    <Button variant="primary" onClick={() => setModalOpen(true)}>New invoice</Button>
  );

  return (
    <div className={styles.page}>
      <PageHeader title="Invoices" subtitle="Everything you have billed" actions={newInvoiceButton} />
      {scenario === 'loading' && <PageLoader />}
      {scenario === 'error' && (
        <ErrorState title="Invoices could not be loaded" action={<Button onClick={clearScenario}>Try again</Button>} />
      )}
      {(scenario === 'populated' || scenario === 'empty') && rows.length === 0 && (
        <EmptyState title="No invoices yet" action={newInvoiceButton} />
      )}
      {(scenario === 'populated' || scenario === 'empty') && rows.length > 0 && (
        <>
          <div className={styles.toolbar}>
            <SelectField
              label="Status"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as MockInvoiceStatus | 'all')}
              options={[{ value: 'all', label: 'All statuses' }, ...invoiceStatusOptions]}
            />
          </div>
          {visibleRows.length > 0 ? (
            <DataTable columns={columns} rows={visibleRows} rowKey={(i) => i.id} />
          ) : (
            <EmptyState
              title="No invoices with this status"
              action={<Button onClick={() => setStatusFilter('all')}>Show all invoices</Button>}
            />
          )}
        </>
      )}
      <NewInvoiceModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onCreate={(input) => {
          createInvoice(input);
          setStatusFilter('all');
          setModalOpen(false);
        }}
      />
    </div>
  );
}
