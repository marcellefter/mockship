import type { ReactNode } from 'react';
import styles from './PageHeader.module.css';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  actions?: ReactNode;
  back?: ReactNode;
}

export function PageHeader({ title, subtitle, actions, back }: PageHeaderProps) {
  return (
    <header className={styles.header}>
      <div>
        {back && <div className={styles.back}>{back}</div>}
        <h1 className={styles.title}>{title}</h1>
        {subtitle && <p className={styles.subtitle}>{subtitle}</p>}
      </div>
      {actions && <div className={styles.actions}>{actions}</div>}
    </header>
  );
}
