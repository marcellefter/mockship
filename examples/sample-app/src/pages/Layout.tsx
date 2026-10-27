import { NavLink, Outlet } from 'react-router';
import { useFlag } from '../flags';
import { useT } from '../i18n';
import styles from './Layout.module.css';

export function Layout() {
  const t = useT();
  const reportsOn = useFlag('reports-beta');
  return (
    <div className={styles.shell}>
      <nav className={styles.nav}>
        <div className={styles.brand}>Acme Billing</div>
        <NavLink to="/customers" className={styles.link}>{t('nav.customers')}</NavLink>
        {reportsOn && <NavLink to="/reports" className={styles.link}>{t('nav.reports')}</NavLink>}
      </nav>
      <main className={styles.main}>
        <Outlet />
      </main>
    </div>
  );
}
