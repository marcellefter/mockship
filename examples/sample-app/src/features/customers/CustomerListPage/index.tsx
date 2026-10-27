import { Link } from 'react-router';
import type { Customer } from '../../../api/client';
import { useT } from '../../../i18n';
import { Button, DataTable, EmptyState, ErrorState, PageHeader, PageLoader, StatusBadge, type Column } from '../../../shared/components';
import { useCustomers } from '../hooks';
import styles from './CustomerListPage.module.css';

export function CustomerListPage() {
  const t = useT();
  const { data, isPending, isError, refetch } = useCustomers();

  const columns: Column<Customer>[] = [
    { key: 'name', header: t('customers.column.name'), render: (c) => <Link to={`/customers/${c.id}`}>{c.name}</Link> },
    { key: 'email', header: t('customers.column.email'), render: (c) => c.email },
    {
      key: 'status',
      header: t('customers.column.status'),
      render: (c) => <StatusBadge tone={c.status === 'active' ? 'success' : 'neutral'} label={t(`customers.status.${c.status}`)} />,
    },
  ];

  return (
    <div className={styles.page}>
      <PageHeader title={t('customers.title')} subtitle={t('customers.subtitle')} />
      {isPending && <PageLoader />}
      {isError && <ErrorState title={t('customers.error')} action={<Button onClick={() => refetch()}>{t('common.retry')}</Button>} />}
      {data && data.length === 0 && <EmptyState title={t('customers.empty')} />}
      {data && data.length > 0 && <DataTable columns={columns} rows={data} rowKey={(c) => c.id} />}
    </div>
  );
}
