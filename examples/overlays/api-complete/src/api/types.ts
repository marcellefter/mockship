export type CustomerStatus = 'active' | 'inactive';

export interface Customer {
  id: string;
  name: string;
  email: string;
  status: CustomerStatus;
  createdAt: string;
}

export type InvoiceStatus = 'draft' | 'sent' | 'paid' | 'overdue' | 'on-hold';

export interface Invoice {
  id: string;
  number: string;
  customerId: string;
  customerName: string;
  total: number;
  currency: string;
  status: InvoiceStatus;
  dueDate: string;
}

export interface CreateInvoiceInput {
  customerId: string;
  total: number;
  currency: string;
  dueDate: string;
}
