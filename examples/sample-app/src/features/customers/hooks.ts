import { useQuery } from '@tanstack/react-query';
import { api } from '../../api/client';

export const customerKeys = {
  all: ['customers'] as const,
  detail: (id: string) => ['customers', id] as const,
};

export function useCustomers() {
  return useQuery({ queryKey: customerKeys.all, queryFn: api.listCustomers });
}

export function useCustomer(id: string) {
  return useQuery({ queryKey: customerKeys.detail(id), queryFn: () => api.getCustomer(id) });
}
