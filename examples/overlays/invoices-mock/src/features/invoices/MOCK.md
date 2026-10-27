# Invoices mock

Status: approved by Ana Popescu on 2026-10-27
<!-- After sign-off, and only when the user says so: approved by <who> on <YYYY-MM-DD> -->

Flag: `invoices-beta` — declared in `FLAGS` in `src/flags.ts` with default `false`; read with
`useFlag('invoices-beta')` in `InvoicesGate` and in the nav link.
Switch it on locally: add `VITE_FLAGS_ON=invoices-beta` to `.env.development.local` (gitignored)
and restart the Vite dev server — Vite reads env files at startup.

## Stack

- Framework / router: React 19 + React Router 7 (`createBrowserRouter`, route table in `src/routes.tsx`), Vite, TypeScript
- Design system / tokens: in-house components in `src/shared/components` (Button, Card/Field, DataTable, Modal, PageHeader, EmptyState/ErrorState/PageLoader, StatusBadge, TextField); CSS variables in `src/theme.css`; CSS modules next to each component
- Flags: static `FLAGS` map in `src/flags.ts`, synchronous `useFlag(name)` / `isFlagOn(name)`, dev override via `VITE_FLAGS_ON`
- Data layer: typed API client `src/api/client.ts` (fake in-browser server `src/api/server.ts`) read through TanStack Query hooks in each feature's `hooks.ts`; entity types in `src/api/types.ts` (`Invoice`, `InvoiceStatus`, `CreateInvoiceInput`, `Customer`)
- i18n: custom `useT()` from `src/i18n`, locales `en` (primary) and `ro`
- Tests: Vitest + Testing Library, `*.test.tsx` next to the component
- Permissions: `useCan(permission)` from `src/auth/permissions.ts`; roles `admin` / `viewer`; `invoices:manage` already granted to `admin` only
- Unknown-route element: `NotFoundPage` (`src/pages/NotFoundPage.tsx`)

## Screens and flow

Source: request text only
Deviations from the source: none

- `/invoices` — invoice list (number, customer, total, status, due date) with a status filter; "New invoice" button for admins
- New invoice modal (from the list) — customer (active customers only), total, currency, due date; creates a Draft invoice that appears at the top of the list
- `/invoices/:id` — invoice detail; admins change the status (applies immediately) or delete the invoice (with a confirm modal)
- Flow: nav "Invoices" → List → Detail → Back to List; List → New invoice modal → List; Detail → Delete → confirm → List (row gone)
- Statuses: Draft (grey), Sent (blue), Paid (green), Overdue (red), **On hold (purple, new)**

## Review links

One row per screen, state and role. Detail links use invoice `i4`, which is On hold. Writes take
a moment, so their in-flight state ("Creating…", "Deleting…", a disabled status picker) shows
on every link.

| Screen | State                     | Role   | Link                                                  |
| ------ | ------------------------- | ------ | ----------------------------------------------------- |
| List   | populated                 | admin  | http://localhost:5199/invoices                        |
| List   | populated                 | viewer | http://localhost:5199/invoices?role=viewer            |
| List   | empty                     | admin  | http://localhost:5199/invoices?scenario=empty         |
| List   | error                     | admin  | http://localhost:5199/invoices?scenario=error         |
| List   | loading                   | admin  | http://localhost:5199/invoices?scenario=loading       |
| List   | filter with no match      | admin  | http://localhost:5199/invoices/i5 — delete INV-1005 (the only Draft), then filter the list by Draft |
| Modal  | New invoice               | admin  | http://localhost:5199/invoices — click "New invoice"  |
| Modal  | create fails              | admin  | http://localhost:5199/invoices?scenario=write-error — click "New invoice", fill it in, submit |
| Detail | populated                 | admin  | http://localhost:5199/invoices/i4                     |
| Detail | populated                 | viewer | http://localhost:5199/invoices/i4?role=viewer         |
| Detail | empty (invoice not found) | admin  | http://localhost:5199/invoices/i4?scenario=empty      |
| Detail | error                     | admin  | http://localhost:5199/invoices/i4?scenario=error      |
| Detail | loading                   | admin  | http://localhost:5199/invoices/i4?scenario=loading    |
| Detail | delete confirm            | admin  | http://localhost:5199/invoices/i4 — click "Delete invoice" |
| Detail | status change fails       | admin  | http://localhost:5199/invoices/i4?scenario=write-error — pick another status |
| Detail | delete fails              | admin  | http://localhost:5199/invoices/i4?scenario=write-error — click "Delete invoice", confirm |

## Review

How reviewers reach the mock: a walkthrough — the user demos it locally to product, with
`VITE_FLAGS_ON=invoices-beta` in `.env.development.local`.

## Access

- Admin and viewer both see the list and the detail page.
- Only admins see "New invoice", the status changer and "Delete invoice". Viewers read only.
- The mock defaults to admin; `?role=viewer` previews the read-only view and is kept on links between mock pages.
- Production mapping: `useCan('invoices:manage')` (already exists, admin only).

## Touchpoints

- `src/flags.ts` — `invoices-beta` flag, default `false`
- `src/routes.tsx` — `/invoices`, `/invoices/:id`, each wrapped in `InvoicesGate`
- `src/pages/Layout.tsx` — "Invoices" nav link, rendered only when `invoices-beta` is on (requested by the user). Label is a plain string; `mock-to-ui` adds `nav.invoices` to `en.json` and `ro.json`

## Local stand-ins

- `InvoiceStatusBadge` — shared `StatusBadge` has no purple tone; "On hold" renders a local badge on `--color-accent-bg` (`#f3e8ff`, the requested colour) / `--color-accent-fg`. The other statuses use the shared `StatusBadge`.
- `SelectField` — the shared components have no select; mirrors `TextField` (label + control) and is used for the status filter, status change, customer and currency.
- `mockStore.ts` — module-level in-memory store so creates, status changes and deletes survive navigation between the mock pages. Replaced by TanStack Query hooks in `mock-to-ui`.
- Page width caps — `960px` / `720px` copied from the Customers pages with a `mockship-allow` marker; the theme has no layout-width token, so `mock-to-ui` should add one.

## Data the screens assume

- Invoice: the existing `Invoice` type (`src/api/types.ts`) — number, customerName, total, currency, status, dueDate. Fixtures are typed with it.
- New status `on-hold` — not in the API's `InvoiceStatus` (`draft | sent | paid | overdue`); the mock widens it locally (`MockInvoiceStatus`). Backend must add it.
- Create invoice: `CreateInvoiceInput` (customerId, total, currency, dueDate); the backend assigns id, number and status `draft` — matches `api.createInvoice`.
- Change status: matches `api.updateInvoiceStatus`.
- **Delete invoice: no endpoint exists** in `src/api/client.ts` — the backend must add one.
- Customers for the picker: the customers the fake server knows (`c1`–`c3`), filtered to `status: 'active'` (Initech is inactive and not offered).

## Decisions

- 2026-10-27 — Status change applies immediately on select (no Save button); delete asks for confirmation.
- 2026-10-27 — Product review: inactive customers (e.g. Initech) are no longer selectable in the New invoice modal (product, via the user).
- 2026-10-27 — Product review: any status change is allowed, including Paid → Draft (product, via the user).
- 2026-10-27 — Product review: any invoice can be deleted, including paid ones (product, via the user).
- 2026-10-27 — Reviewers reach the mock through a local walkthrough demoed by the user.
- 2026-10-27 — Approved by Ana Popescu.
- 2026-10-27 — New invoices start as Draft, as the existing `createInvoice` endpoint does.
- 2026-10-27 — Detail "empty" state is "This invoice does not exist" (what a deleted or unknown id shows).
- 2026-10-27 — `?scenario=empty` always shows the empty list, so an invoice created from the empty state's "New invoice" button only appears once the parameter is removed.

## Open questions

- Does "On hold" mean anything for due-date / overdue handling? (Not raised in review; the mock treats it as a plain status.)

## Promotion

<!-- Filled in by mock-to-ui; ui-to-mock leaves this empty. -->
