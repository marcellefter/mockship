import { useT } from '../i18n';
import { EmptyState } from '../shared/components';

export function NotFoundPage() {
  const t = useT();
  return <EmptyState title={t('common.notFound')} />;
}
