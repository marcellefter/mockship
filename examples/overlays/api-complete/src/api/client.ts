// The app's API client. Every operation the backend supports is listed here.
import { server } from './server';

export { NotFoundError } from './server';
import type { CreateInvoiceInput, Customer, Invoice, InvoiceStatus } from './types';

export type { CreateInvoiceInput, Customer, Invoice, InvoiceStatus } from './types';

export const api = {
  listCustomers: (): Promise<Customer[]> => server.listCustomers(),
  getCustomer: (id: string): Promise<Customer> => server.getCustomer(id),
  listInvoices: (): Promise<Invoice[]> => server.listInvoices(),
  getInvoice: (id: string): Promise<Invoice> => server.getInvoice(id),
  createInvoice: (input: CreateInvoiceInput): Promise<Invoice> => server.createInvoice(input),
  deleteInvoice: (id: string): Promise<void> => server.deleteInvoice(id),
  updateInvoiceStatus: (id: string, status: InvoiceStatus): Promise<Invoice> => server.updateInvoiceStatus(id, status),
};
