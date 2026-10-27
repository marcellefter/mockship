import { useSearchParams } from 'react-router';
import type { Role } from '../../auth/permissions';

export type Scenario = 'populated' | 'empty' | 'error' | 'loading';

// Mock-only review switches: ?scenario=empty|error|loading and ?role=viewer.
export function useReviewParams() {
  const [params, setParams] = useSearchParams();
  const raw = params.get('scenario');
  const scenario: Scenario = raw === 'empty' || raw === 'error' || raw === 'loading' ? raw : 'populated';
  const role: Role = params.get('role') === 'viewer' ? 'viewer' : 'admin';
  const withRole = (path: string) => (role === 'viewer' ? `${path}?role=viewer` : path);
  const clearScenario = () => {
    params.delete('scenario');
    setParams(params);
  };
  return { scenario, role, canManage: role === 'admin', withRole, clearScenario };
}
