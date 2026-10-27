# <Feature> mock

Status: draft
<!-- After sign-off, and only when the user says so: approved by <who> on <YYYY-MM-DD> -->

Flag: `<flag-name>`, <where it is declared and how code reads it>
Switch it on locally: <env var, override file, flag-service environment>

## Stack

- Framework / router: <e.g. React 19 + React Router 7>
- Design system / tokens: <e.g. MUI theme, CSS variables in src/theme.css>
- Flags: <mechanism>
- Data layer: <e.g. generated OpenAPI client + TanStack Query in src/api>
- i18n: <library and locales, or "none">
- Tests: <runner + library, or "none">
- Permissions: <how the app checks access, or "none">

## Screens and flow

Source: <design file, screenshot or sketch link, or "request text only">
Deviations from the source: <what differs and why, or "none">

- `/invoices`: list of invoices with status filter
- `/invoices/:id`: invoice detail with status change and delete
- Flow: List → Detail → back to List; List → "New invoice" modal → List

## Review links

One row per screen, state and role. Write a short instruction after the link when a state
needs a click (a modal, a confirmation).

| Screen | State       | Role   | Link                                                |
| ------ | ----------- | ------ | --------------------------------------------------- |
| List   | populated   | admin  | http://localhost:5173/invoices                      |
| List   | populated   | viewer | http://localhost:5173/invoices?role=viewer          |
| List   | empty       | admin  | http://localhost:5173/invoices?scenario=empty       |
| List   | error       | admin  | http://localhost:5173/invoices?scenario=error       |
| List   | loading     | admin  | http://localhost:5173/invoices?scenario=loading     |
| List   | write fails | admin  | http://localhost:5173/invoices?scenario=write-error, then click "New invoice" and submit |

## Review

How reviewers reach the mock: <preview deployment / flag targeting / walkthrough>

## Access

- Everyone who can see invoices sees the list and detail.
- Only `billing-admin` can delete or change status. (`?role=viewer` previews the read-only view.)

## Touchpoints

- `src/flags.ts`: flag constant, default off
- `src/routes.tsx`: `/invoices`, `/invoices/:id`
- `app/invoices/`: with a file-based router, every route file under it, each only importing
  from the feature folder

## Local stand-ins

- `components/InvoiceStatusBadge`: shared `StatusBadge` has no "overdue" tone

## Data the screens assume

- Invoice: number, customer, total, status, due date. No API type exists yet.
- Writes: create invoice, change status, delete invoice

## Decisions

- <date>: Removed the bulk-delete button after review (<who>).

## Open questions

- Who can void an invoice that is already paid?

## Promotion

<!-- Filled in by mock-to-ui; ui-to-mock leaves this empty. -->
