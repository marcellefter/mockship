import { Link, useParams } from 'react-router';
import { useCan } from '../../../auth/permissions';
import { useT } from '../../../i18n';
import { Button, Card, ErrorState, Field, PageHeader, PageLoader, StatusBadge } from '../../../shared/components';
import { useCustomer } from '../hooks';
import styles from './CustomerDetailPage.module.css';

export function CustomerDetailPage() {
  const t = useT();
  const { id = '' } = useParams();
  const canEdit = useCan('customers:edit');
  const { data, isPending, isError } = useCustomer(id);

  if (isPending) return <PageLoader />;
  if (isError) return <ErrorState title={t('customers.error')} />;

  return (
    <div className={styles.page}>
      <PageHeader
        back={<Link to="/customers">← {t('common.back')}</Link>}
        title={data.name}
        subtitle={t('customers.detail.since', { date: data.createdAt })}
        actions={canEdit && <Button variant="primary">{t('customers.detail.edit')}</Button>}
      />
      <Card>
        <Field label={t('customers.column.email')}>{data.email}</Field>
        <Field label={t('customers.column.status')}>
          <StatusBadge tone={data.status === 'active' ? 'success' : 'neutral'} label={t(`customers.status.${data.status}`)} />
        </Field>
      </Card>
    </div>
  );
}
