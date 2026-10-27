// Stands in for the backend. UI code must go through ./client.ts, never this file.
import type { CreateInvoiceInput, Customer, Invoice, InvoiceStatus } from './types';

const customers: Customer[] = [
  { id: 'c1', name: 'Northwind Traders', email: 'billing@northwind.test', status: 'active', createdAt: '2025-02-11' },
  { id: 'c2', name: 'Globex', email: 'ap@globex.test', status: 'active', createdAt: '2025-05-03' },
  { id: 'c3', name: 'Initech', email: 'finance@initech.test', status: 'inactive', createdAt: '2024-11-20' },
];

const invoices: Invoice[] = [
  { id: 'i1', number: 'INV-1001', customerId: 'c1', customerName: 'Northwind Traders', total: 1200, currency: 'EUR', status: 'paid', dueDate: '2026-09-01' },
  { id: 'i2', number: 'INV-1002', customerId: 'c2', customerName: 'Globex', total: 860.5, currency: 'EUR', status: 'sent', dueDate: '2026-11-15' },
];

const delay = <T,>(value: T) => new Promise<T>((resolve) => setTimeout(() => resolve(structuredClone(value)), 300));
const notFound = () => Promise.reject(new Error('Not found'));

export const server = {
  listCustomers: () => delay(customers),
  getCustomer: (id: string) => {
    const c = customers.find((x) => x.id === id);
    return c ? delay(c) : notFound();
  },
  listInvoices: () => delay(invoices),
  getInvoice: (id: string) => {
    const i = invoices.find((x) => x.id === id);
    return i ? delay(i) : notFound();
  },
  createInvoice: (input: CreateInvoiceInput) => {
    const customer = customers.find((c) => c.id === input.customerId);
    if (!customer) return notFound();
    const invoice: Invoice = {
      id: `i${invoices.length + 1}`,
      number: `INV-${1001 + invoices.length}`,
      customerName: customer.name,
      status: 'draft',
      ...input,
    };
    invoices.push(invoice);
    return delay(invoice);
  },
  updateInvoiceStatus: (id: string, status: InvoiceStatus) => {
    const i = invoices.find((x) => x.id === id);
    if (!i) return notFound();
    i.status = status;
    return delay(i);
  },
};
