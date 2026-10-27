# Acme Billing — agent notes

A small React app used as the test fixture for the mockship skills.

## Stack

- React 19 + React Router 7 (`src/routes.tsx`), Vite, TypeScript.
- Data: typed API client in `src/api/client.ts` (talks to an in-browser fake server in
  `src/api/server.ts`), read through TanStack Query hooks in each feature's `hooks.ts`.
  Never call `src/api/server.ts` directly from UI code, and never edit it to add an endpoint —
  it stands in for the backend.
- Styling: CSS modules next to each component (`Component.module.css`). Every colour, size,
  radius and spacing comes from the CSS variables in `src/theme.css`.
- Shared UI: `src/shared/components` (import from `src/shared/components/index.ts`).
- Permissions: `useCan(permission)` from `src/auth/permissions.ts`.
- i18n: `useT()` from `src/i18n`; keys in `src/i18n/locales/en.json` and `ro.json` (both
  locales always).
- Tests: Vitest + Testing Library, `*.test.tsx` next to the code. `npm test`.

## Conventions

- Features live in `src/features/<kebab-name>/`, one PascalCase folder per component with
  `index.tsx` and `<Name>.module.css`.
- Named exports only. Callback props are `on<Event>`.

## Quality gates

`npm run typecheck` and `npm test` must pass before a commit.
