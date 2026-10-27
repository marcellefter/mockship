---
name: mock-to-ui
description: Promote an approved UI mock built with ui-to-mock into production code — real API data, translations, tests, shared components and the project's conventions — while keeping the approved look and flow. Use when a mock has been signed off and must ship, or when a feature folder contains a MOCK.md.
license: MIT
metadata:
  author: marcellefter
  version: "1.0.0"
---

# Mock to UI

The input is a feature folder built by the `ui-to-mock` skill: clickable, flag-gated, fake
data, plain-text copy, no tests, and a `MOCK.md` listing everything it touched. The output is
the same feature as production code.

**The mock is the spec.** Layout, flow, copy and states were approved as they are. Every
change below is to how the feature is built, never to what a user sees. When a production
constraint forces a visible change — the API cannot sort that column, a permission hides that
button — show it to the user and let them decide.

**The flag stays.** The feature keeps shipping dark behind the mock's flag and gate. Turning it
on, and later removing it, is a rollout decision for the product owner, outside this skill.

Each step below defers to the project's own conventions for its subject: `AGENTS.md`,
`CLAUDE.md`, `CONTRIBUTING.md`, and any installed skill that covers it (API usage, components,
i18n, testing, design review). This skill only sets the order and the finish line for each
step.

## 1. Inventory

Read `MOCK.md`, then every file in the feature folder. With no `MOCK.md` (a mock built
without `ui-to-mock`), rebuild one first from the diff against the branch's merge base.

**Done when** every file is classed as page, component, local stand-in, data or gate, and
every touchpoint in `MOCK.md` is confirmed present in the code.

## 2. Contract

For every entry under _Data the screens assume_ and every write the screens perform, find the
real operation the frontend will call — a generated API client operation, an existing service
function, a GraphQL query or mutation.

**Done when** each read and write maps to a named operation. Any that does not is a **gap**:
list the gaps for the user and **stop** until they say how to proceed. A gap is closed by the
backend (or whoever owns the API), never by a hand-written request around the project's API
layer or an edit to a generated client.

## 3. Reuse

Walk _Local stand-ins_ and then every component in the folder, and resolve each one:

- **An existing shared or app component already does it** — use that and delete the local one.
- **It is a variant of a shared component** — extend the shared component in place, keeping
  its current callers unchanged, and add the stories, docs or tests the shared code expects.
- **It is genuinely new** — keep it in the feature. It moves to shared code only when a second
  feature or app needs it.

**Done when** every stand-in in `MOCK.md` has one of those three outcomes, and no feature file
duplicates rules from a shared component or the theme.

## 4. Structure

Apply the project's component conventions in full — when to split a component, where hooks
and utilities are extracted to, barrel files only where something outside the folder imports
— and its rules for state, effects and memoization.

**Done when** every component reads as markup: it calls hooks (or the stack's equivalent) and
renders.

## 5. Data

Replace the in-memory state with the project's data layer on the operations from step 2 — its
data-fetching library, cache invalidation and API error display, the way neighbouring
features do it. Give each list and page the loading, empty and error states the design system
defines, which the mock never needed.

**Done when** nothing imports the `mockData` module and it is deleted.

## 6. Text

Move every literal into the project's i18n system, in every locale the app ships. The wording
approved in the mock is the primary-language translation. If the project has no i18n, skip
this step and say so in the report.

**Done when** every user-visible string in the folder — including `aria-label`, `title` and
placeholder props — goes through the translation function.

## 7. Tests

Follow the project's testing conventions. Cover what the mock proved matters: the flag gate
(off renders not-found, on renders the page), the utilities and hooks extracted in step 4, and
the interactions the reviewers clicked through. Run the test files you wrote.

**Done when** those files pass and each test would fail if the behaviour it names broke.

## 8. Review and hand-off

Review the feature folder against the project's design and code-review standards and fix what
the review finds. Delete `MOCK.md`; move its open questions into the pull request description.
At commit time the project's quality gates apply (lint, type-check, tests, PR checklist).

**Done when** `MOCK.md` and the `mockData` module are gone, the flag and gate are still in
place, and the report names any gap from step 2 and any visible change the user approved.
