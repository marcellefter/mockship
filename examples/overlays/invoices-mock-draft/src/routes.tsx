import { Navigate, type RouteObject } from 'react-router';
import { CustomerDetailPage } from './features/customers/CustomerDetailPage';
import { CustomerListPage } from './features/customers/CustomerListPage';
import { InvoiceDetailPage } from './features/invoices/InvoiceDetailPage';
import { InvoiceListPage } from './features/invoices/InvoiceListPage';
import { InvoicesGate } from './features/invoices/InvoicesGate';
import { isFlagOn } from './flags';
import { Layout } from './pages/Layout';
import { NotFoundPage } from './pages/NotFoundPage';
import { ReportsPage } from './pages/ReportsPage';

export const routes: RouteObject[] = [
  {
    element: <Layout />,
    children: [
      { index: true, element: <Navigate to="/customers" replace /> },
      { path: 'customers', element: <CustomerListPage /> },
      { path: 'customers/:id', element: <CustomerDetailPage /> },
      { path: 'invoices', element: <InvoicesGate><InvoiceListPage /></InvoicesGate> },
      { path: 'invoices/:id', element: <InvoicesGate><InvoiceDetailPage /></InvoicesGate> },
      { path: 'reports', element: isFlagOn('reports-beta') ? <ReportsPage /> : <NotFoundPage /> },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
];
