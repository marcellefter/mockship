---
name: ui-to-mock
description: Build a clickable UI mock of a screen or flow inside the real app — behind a feature flag that defaults off, with fake in-memory data, plain-text copy and no tests. Use when asked to mock, prototype or click-through a page or feature in an existing frontend codebase before the backend or sign-off exists. Promoting an approved mock to production code is the mock-to-ui skill.
license: MIT
metadata:
  author: marcellefter
  version: "1.0.0"
---

# UI to mock

A **mock** is a clickable prototype that lives in the real app: real routes, real layout shell,
real theme, fake data. It exists so people can click through a flow and approve it before
anyone builds a backend. Two things matter — **speed** and **visual consistency** with the
rest of the app. Everything that makes code production-grade is deferred to the `mock-to-ui`
skill, which runs once the mock is approved.

Before starting, read the project's own agent and contributor docs (`AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, or similar). Where they set a convention — folder layout, naming, styling,
flags — follow it; this skill only adds the rules that make a mock a mock.

## The boundary

All mock code lives in **one feature folder**, placed and named the way the project places
features (for example `src/features/<feature>/`, or `apps/<app>/src/features/<feature>/` in a
monorepo). If the project has no feature-folder convention, ask where it goes.

**Shared code is read-only.** Import any shared components, hooks, utilities and theme the
project's module boundaries allow, and use them as-is. When a shared piece nearly fits, build
the variant inside the mock folder and list it under _Local stand-ins_ in `MOCK.md`. The mock
never edits a file outside its folder, except these **touchpoints**, which are the complete
list:

| Touchpoint         | Where                                                                      |
| ------------------ | -------------------------------------------------------------------------- |
| The flag           | wherever the project declares feature flags                                |
| One route per page | the project's route table or router config                                 |
| An entry point     | a menu item or a link on an existing screen — only when the user asks for one |

## 1. Flag first

Every mock ships dark, so the flag exists before the first screen does.

1. Find how the project already declares feature flags (a flags module, a feature-flag service
   such as Unleash, LaunchDarkly, GrowthBook or Flagsmith, a config file). Add the new flag
   exactly the way existing flags are added — same naming pattern, same helpers.
   **Its default is always off.**
2. If the project has no feature-flag mechanism, **stop and ask the user** where the flag
   goes. A mock never invents a flag system on its own.
3. Write one **gate** component in the mock folder and wrap **every** mock page in it: render
   the app's loading state until flags are resolved (if the flag client is asynchronous), then
   the page when the flag is on, otherwise the same not-found element the app renders for an
   unknown route.
4. Any entry point the user asked for renders only when the flag is on.

The off default keeps the mock invisible everywhere, including in a deployed environment where
the flag was never created in the flag service. Tell the user how to switch it on locally —
the project's local override if it has one, otherwise the flag service's development
environment.

## 2. Build the screens

**Clickable, not static.** A reviewer must be able to walk the whole flow:

- Each mock page is a real route, and pages link to each other with the router.
- Tabs, modals, drawers, filters, sorting, pagination and form submits work, driven by local
  component state.
- Writes change the in-memory data: a created row appears in the list, a deleted one goes.

**Data** lives in one `mockData` module at the feature root (`mockData.ts`, `mock_data.py`,
whatever fits the stack): typed fixtures that seed the page state. When the entity already
has a type in the project — a generated API client, a shared model — type the fixtures with
it, so `mock-to-ui` swaps the source without reshaping anything. Data never touches the
network: no API client calls, data-fetching library, `fetch`, or request mocking (MSW and the
like).

**Copy** is plain string literals in the markup, in the app's primary language — no i18n
calls, no locale files. Casing and wording still follow the project's copy guidelines, if it
has any.

**Visual consistency** comes from two sources:

- **The design system.** Use the project's component library first, then its theme tokens
  (CSS variables, a theme object, Tailwind config, design tokens) for anything custom. Every
  colour, size, radius and spacing is a token — never a literal. If the project has a design
  skill or style guide, load it before the first screen.
- **Match the neighbour.** Find the nearest real page in the same app with a similar shape
  (list, detail, settings, wizard) and reuse its page shell, header, toolbar and table
  components rather than composing new ones.

**Structure**: follow the project's component placement and naming conventions — file and
folder casing, where styles live, export style, callback naming. It costs nothing now and
saves `mock-to-ui` a move. Leave splitting large components, extracting hooks and utilities,
and barrel files for `mock-to-ui`.

## What mock-to-ui owns

The mock leaves these to `mock-to-ui`, so they stay out of the mock even when they feel quick:
test files, translation keys, API clients and data fetching, API error handling, permission
checks, and any edit to shared code. Running lint, type-check or tests while iterating is
likewise out — but the project's normal quality gates apply unchanged when the user asks to
commit, because a merged mock is still merged code.

## 3. Write MOCK.md

`MOCK.md` at the feature root is the hand-off to `mock-to-ui`. Keep it current as you build:

```markdown
# Invoices mock

Flag: `feature-invoices` — declared in `src/flags.ts` (`INVOICES_FLAG`, `useHasInvoices`)

## Touchpoints

- `src/flags.ts` — flag constant, default off, hook
- `src/routes.ts` — `/invoices`, `/invoices/:id`

## Local stand-ins

- `components/InvoiceStatusBadge` — shared `StatusBadge` has no "overdue" tone

## Data the screens assume

- Invoice: number, customer, total, status, due date — no API type exists yet
- Writes: create invoice, change status, delete invoice

## Open questions

- Who can void an invoice that is already paid?
```

## Done when

- Every requested screen is reachable by clicking from the first mock page with the flag on,
  and every interaction above works against the in-memory data.
- With the flag off, every mock route renders the not-found element and no entry point shows.
- The **boundary check** lists only the mock folder plus the touchpoints in `MOCK.md`
  (replace `main` with the branch the work is based on):

  ```bash
  git diff --name-only "$(git merge-base origin/main HEAD)"
  git ls-files --others --exclude-standard
  ```

- No literal colour or pixel value in the mock folder — this prints nothing (adjust the
  pattern if the project's tokens are themselves written in px):

  ```bash
  grep -rnE "#[0-9a-fA-F]{3,8}\b|[0-9]+px|rgba?\(" <path-to-feature-folder>
  ```

Report the route URL, the flag name, how to switch it on locally, and the `MOCK.md` stand-ins
and open questions. If you could not open the mock in a browser, say so.
