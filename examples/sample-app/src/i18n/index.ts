import en from './locales/en.json';
import ro from './locales/ro.json';

const locales = { en, ro } as const;
export type Locale = keyof typeof locales;
export type MessageKey = keyof typeof en;

function currentLocale(): Locale {
  try {
    return localStorage.getItem('acme-locale') === 'ro' ? 'ro' : 'en';
  } catch {
    return 'en';
  }
}

export function translate(key: MessageKey, vars: Record<string, string | number> = {}, locale = currentLocale()): string {
  const template: string = (locales[locale] as Record<string, string>)[key] ?? en[key] ?? key;
  return template.replace(/\{(\w+)\}/g, (_, name: string) => String(vars[name] ?? `{${name}}`));
}

export function useT() {
  return translate;
}
