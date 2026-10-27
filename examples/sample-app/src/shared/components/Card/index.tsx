import type { ReactNode } from 'react';
import styles from './Card.module.css';

export function Card({ children }: { children: ReactNode }) {
  return <section className={styles.card}>{children}</section>;
}

export function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className={styles.field}>
      <dt>{label}</dt>
      <dd>{children}</dd>
    </div>
  );
}
