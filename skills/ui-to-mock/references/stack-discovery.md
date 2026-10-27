# Stack discovery

Answer each question from the code before building, and write the answers under _Stack_ in
`MOCK.md`. `mock-to-ui` relies on them. When an answer is "none", write "none". Don't guess.

## 0. Which app?

In a monorepo (`apps/`, `packages/`, a `pnpm-workspace.yaml`, `nx.json`, `turbo.json`), find
the app the request is about. If the request does not say and more than one app fits, ask.

## 1. Framework and router

Look at the app's `package.json` dependencies and its entry file.

| Signal | Stack |
| --- | --- |
| `react-router`, `react-router-dom`, `@tanstack/react-router` | React SPA router |
| `next` | Next.js: check for `app/` (App Router) or `pages/` |
| `vue-router`, `nuxt` | Vue / Nuxt |
| `@sveltejs/kit` | SvelteKit (file-based routes under `src/routes/`) |
| `@angular/router` | Angular |
| `@remix-run/*`, `react-router` with `routes.ts` | Remix / React Router framework mode |

Find the route table (or route folder) and the element rendered for an unknown route. The
mock's gate renders that same element when the flag is off.

## 2. Design system and tokens

- Component library: `@mui/*`, `antd`, `@chakra-ui/*`, `@mantine/*`, `@radix-ui/*` /
  shadcn (`components/ui/`), `vuetify`, `@angular/material`, or an in-house package.
- Tokens: a theme object (`createTheme`, `ConfigProvider theme`), CSS custom properties
  (`:root { --… }`), `tailwind.config.*` / `@theme` in CSS, or a tokens package.
- How styles are written next to components: CSS modules, styled-components / Emotion,
  Tailwind classes, a `createStyles` helper, SCSS.

## 3. Feature flags

Search for `flag`, `feature`, `toggle`, `unleash`, `launchdarkly`, `growthbook`,
`flagsmith`, `posthog` `isFeatureEnabled`. Note how a flag is declared, how code reads it, its
default, and whether reading is asynchronous (needs a "ready" check). No hit means no flag
mechanism; see the "No flag mechanism" section of `gates.md`.

## 4. Data layer

- API client: a generated OpenAPI client (`openapi-ts`, `orval`, `openapi-generator`), GraphQL
  (`@apollo/client`, `urql`, codegen), tRPC, or hand-written `fetch` wrappers.
- Fetching and caching: TanStack Query, SWR, RTK Query, Apollo, Pinia stores, Angular services.
- Existing types for the entity the mock shows. Type `mockData` with them.

## 5. i18n

`i18next` / `react-i18next`, `vue-i18n`, `@angular/localize`, `next-intl`, `lingui`,
`formatjs`. Note the locales the app ships. No library means the mock's copy stays as-is.

## 6. Tests

`vitest`, `jest`, `@testing-library/*`, `playwright`, `cypress`, Storybook. Note where tests
live and how they are named.

## 7. Permissions

How the app hides routes and actions: route guards, a `can()` / `usePermission()` helper,
role checks on the user object, or nothing. `mock-to-ui` maps _Access_ onto this.
