export type Role = 'admin' | 'viewer';
export type Permission = 'customers:edit' | 'invoices:manage';

const grants: Record<Role, Permission[]> = {
  admin: ['customers:edit', 'invoices:manage'],
  viewer: [],
};

export function currentRole(): Role {
  try {
    return localStorage.getItem('acme-role') === 'viewer' ? 'viewer' : 'admin';
  } catch {
    return 'admin';
  }
}

export function useCan(permission: Permission): boolean {
  return grants[currentRole()].includes(permission);
}
