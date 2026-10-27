import type { Customer, Invoice, InvoiceStatus } from '../../api/client';

// "On hold" is new: the API's InvoiceStatus does not have it yet.
export type MockInvoiceStatus = InvoiceStatus | 'on-hold';

export type MockInvoice = Omit<Invoice, 'status'> & { status: MockInvoiceStatus };

export const invoiceStatusOptions: { value: MockInvoiceStatus; label: string }[] = [
  { value: 'draft', label: 'Draft' },
  { value: 'sent', label: 'Sent' },
  { value: 'paid', label: 'Paid' },
  { value: 'overdue', label: 'Overdue' },
  { value: 'on-hold', label: 'On hold' },
];

export const currencyOptions = ['EUR', 'USD'];

export const mockCustomers: Customer[] = [
  { id: 'c1', name: 'Northwind Traders', email: 'billing@northwind.test', status: 'active', createdAt: '2025-02-11' },
  { id: 'c2', name: 'Globex', email: 'ap@globex.test', status: 'active', createdAt: '2025-05-03' },
  { id: 'c3', name: 'Initech', email: 'finance@initech.test', status: 'inactive', createdAt: '2024-11-20' },
];

export const mockInvoices: MockInvoice[] = [
  { id: 'i1', number: 'INV-1001', customerId: 'c1', customerName: 'Northwind Traders', total: 1200, currency: 'EUR', status: 'paid', dueDate: '2026-09-01' },
  { id: 'i2', number: 'INV-1002', customerId: 'c2', customerName: 'Globex', total: 860.5, currency: 'EUR', status: 'sent', dueDate: '2026-11-15' },
  { id: 'i3', number: 'INV-1003', customerId: 'c3', customerName: 'Initech', total: 4320, currency: 'EUR', status: 'overdue', dueDate: '2026-10-05' },
  { id: 'i4', number: 'INV-1004', customerId: 'c1', customerName: 'Northwind Traders', total: 275.9, currency: 'EUR', status: 'on-hold', dueDate: '2026-11-30' },
  { id: 'i5', number: 'INV-1005', customerId: 'c2', customerName: 'Globex', total: 1999, currency: 'USD', status: 'draft', dueDate: '2026-12-10' },
  { id: 'i6', number: 'INV-1006', customerId: 'c1', customerName: 'Northwind Traders', total: 640, currency: 'EUR', status: 'sent', dueDate: '2026-11-20' },
  { id: 'i7', number: 'INV-1007', customerId: 'c3', customerName: 'Initech', total: 150, currency: 'EUR', status: 'on-hold', dueDate: '2026-12-01' },
];
