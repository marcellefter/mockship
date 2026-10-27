import type { ReactNode } from 'react';
import styles from './States.module.css';

export function PageLoader() {
  return <div className={styles.loader} role="status" aria-label="Loading" />;
}

export function EmptyState({ title, action }: { title: string; action?: ReactNode }) {
  return (
    <div className={styles.box}>
      <p className={styles.title}>{title}</p>
      {action}
    </div>
  );
}

export function ErrorState({ title, action }: { title: string; action?: ReactNode }) {
  return (
    <div className={`${styles.box} ${styles.error}`} role="alert">
      <p className={styles.title}>{title}</p>
      {action}
    </div>
  );
}
