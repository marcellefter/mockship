import { useT } from '../i18n';
import { PageHeader } from '../shared/components';

export function ReportsPage() {
  const t = useT();
  return <PageHeader title={t('reports.title')} />;
}
