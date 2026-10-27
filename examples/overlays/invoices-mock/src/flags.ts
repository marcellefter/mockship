// Every feature flag, with its default. Defaults are always false.
export const FLAGS = {
  'reports-beta': false,
  'invoices-beta': false,
} satisfies Record<string, boolean>;

export type FlagName = keyof typeof FLAGS;

// Local override for development: VITE_FLAGS_ON=reports-beta,other-flag
const forcedOn = new Set(
  import.meta.env.DEV ? (import.meta.env.VITE_FLAGS_ON ?? '').split(',').map((s: string) => s.trim()) : [],
);

export function isFlagOn(name: FlagName): boolean {
  return forcedOn.has(name) || FLAGS[name];
}

export function useFlag(name: FlagName): boolean {
  return isFlagOn(name);
}
