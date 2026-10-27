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

// Writes take a moment so reviewers see the in-flight state, and fail under ?scenario=write-error.
function simulateWrite<T>(fails: boolean, apply: () => T): Promise<T> {
  return new Promise((resolve, reject) => {
    setTimeout(() => (fails ? reject(new Error('Write failed')) : resolve(apply())), 600);
  });
}

export function useMockInvoices(): MockInvoice[] {
  return useSyncExternalStore(subscribe, () => invoices);
}

export function createInvoice(input: CreateInvoiceInput, fails: boolean): Promise<MockInvoice> {
  return simulateWrite(fails, () => {
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
  });
}

export function updateInvoiceStatus(id: string, status: MockInvoiceStatus, fails: boolean): Promise<void> {
  return simulateWrite(fails, () => setInvoices(invoices.map((i) => (i.id === id ? { ...i, status } : i))));
}

export function deleteInvoice(id: string, fails: boolean): Promise<void> {
  return simulateWrite(fails, () => setInvoices(invoices.filter((i) => i.id !== id)));
}
