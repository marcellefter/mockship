import { Navigate, type RouteObject } from 'react-router';
import { CustomerDetailPage } from './features/customers/CustomerDetailPage';
import { CustomerListPage } from './features/customers/CustomerListPage';
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
      { path: 'reports', element: isFlagOn('reports-beta') ? <ReportsPage /> : <NotFoundPage /> },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
];
