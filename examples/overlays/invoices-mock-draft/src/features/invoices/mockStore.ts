import { useSyncExternalStore } from 'react';
import type { CreateInvoiceInput } from '../../api/client';
import { mockCustomers, mockInvoices, type MockInvoice, type MockInvoiceStatus } from './mockData';

// In-memory invoices shared by the mock pages. Resets on page reload.
let invoices: MockInvoice[] = mockInvoices;
const listeners = new Set<() => void>();

function setInvoices(next: MockInvoice[]) {
  invoices = next;
  listeners.forEach((listener) => listener());
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

export function useMockInvoices(): MockInvoice[] {
  return useSyncExternalStore(subscribe, () => invoices);
}

export function createInvoice(input: CreateInvoiceInput): MockInvoice {
  const lastNumber = Math.max(1000, ...invoices.map((i) => Number(i.number.replace('INV-', ''))));
  const customer = mockCustomers.find((c) => c.id === input.customerId);
  const invoice: MockInvoice = {
    ...input,
    id: `i${Date.now()}`,
    number: `INV-${lastNumber + 1}`,
    customerName: customer?.name ?? '',
    status: 'draft',
  };
  setInvoices([invoice, ...invoices]);
  return invoice;
}

export function updateInvoiceStatus(id: string, status: MockInvoiceStatus) {
  setInvoices(invoices.map((i) => (i.id === id ? { ...i, status } : i)));
}

export function deleteInvoice(id: string) {
  setInvoices(invoices.filter((i) => i.id !== id));
}
