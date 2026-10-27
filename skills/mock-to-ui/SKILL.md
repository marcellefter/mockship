---
name: mock-to-ui
description: Promote an approved UI mock built with ui-to-mock into production code — real API data, access checks, translations, tests, shared components and the project's conventions — and prove it still looks and flows like the approved mock. Use when a mock has been signed off and must ship, or when a feature folder contains a MOCK.md.
license: MIT
metadata:
  author: marcellefter
  version: "1.1.1"
---

# Mock to UI

The input is a feature folder built by the `ui-to-mock` skill: clickable, flag-gated, fake
data with reviewable states, plain-text copy, no tests, and a `MOCK.md` listing everything it
touched. The output is the same feature as production code.

**The mock is the spec.** Layout, flow, copy and every state behind a review link were
approved as they are. Every change below is to how the feature is built, never to what a user
sees. When a production constraint forces a visible change — the API cannot sort that column,
a state the mock never showed — show it to the user and let them decide.

**The flag stays.** The feature keeps shipping dark behind the mock's flag and gate. Turning it
on, and later removing it, is a rollout decision for the product owner, outside this skill.

Each step defers to the project's own conventions for its subject: `AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, and any installed skill that covers it (API usage, components, i18n,
testing, design review). _Stack_ in `MOCK.md` names the libraries; this skill sets the order
and the finish line for each step.

## 1. Inventory and sign-off

Read `MOCK.md`, then every file in the feature folder.

- **Sign-off.** _Status_ must read `approved — <who>, <date>`. If it still reads `draft`, ask
  the user who approved the mock and when, and record it, before changing any code. Never
  assume approval.
- **No `MOCK.md`** (a mock built without `ui-to-mock`): rebuild one from the diff against the
  branch's merge base with these sections — Status, Flag, Stack, Screens and flow, Review
  links, Review, Access, Touchpoints, Local stand-ins, Data the screens assume, Decisions,
  Open questions — and confirm the gaps in it with the user.
- **A development-only switch** (a route or URL switch that only exists in development
  builds) cannot ship. Ask the user which shippable switch replaces it — a build-time env var
  or a flag service — and make the swap part of this work.

**Done when** the mock is recorded as approved, the flag can ship, every file is classed as page, component,
local stand-in, data, review helper or gate, and every touchpoint in `MOCK.md` is confirmed
present in the code.

## 2. Baseline

With the flag on, open every row of _Review links_ and save a screenshot of each — every
screen in every state and role — to a folder **outside the repository** (a temp or scratch
directory). Use whatever browser automation you have: a browser tool, Playwright, or headless
Chrome (`--headless --screenshot`). These are what the result is compared against in step 10.

**Done when** there is one screenshot per review link. If you have no way to take screenshots,
say so now: step 10 then becomes a walkthrough the user does against the mock, and the report
must say the comparison was manual.

## 3. Contract

For every entry under _Data the screens assume_ and every write the screens perform, find the
real operation the frontend will call — a generated API client operation, an existing service
function, a GraphQL query or mutation.

**Done when** each read and write maps to a named operation. Any that does not is a **gap**.
For each gap, draft the missing contract from the mock — the operation, a suggested method and
path, request fields and response fields taken from the `mockData` types, and the screen that
needs it — give the drafts to the user for the API owner, and **stop** until the user says how
to proceed. Step 4 (Access) may still run while you wait; steps 5 onward wait, because the
answers can change what ships. A gap is closed by the backend, never by a hand-written request around the
project's API layer or an edit to a generated client.

## 4. Access

Map every line under _Access_ onto the project's permission mechanism — route guards, a
`can()` helper, role checks — so each screen and action shows exactly for the roles the mock
showed it to. A role or permission the app does not have is a gap: report it as in step 3 and
stop. When _Access_ says everyone sees everything, confirm that against the routes the feature
sits under and move on.

**Done when** every _Access_ line is enforced by real checks, and the mock's `role` URL
parameter is gone.

## 5. Reuse

Walk _Local stand-ins_ and then every component in the folder, and resolve each one:

- **An existing shared or app component already does it** — use that and delete the local one.
- **It is a variant of a shared component** — extend the shared component in place, keeping
  its current callers unchanged, and add the stories, docs or tests the shared code expects.
- **It is genuinely new** — keep it in the feature. It moves to shared code only when a second
  feature or app needs it.

**Done when** every stand-in in `MOCK.md` has one of those three outcomes, and no feature file
duplicates rules from a shared component or the theme.

## 6. Structure

Apply the project's component conventions in full — when to split a component, where hooks
and utilities are extracted to, barrel files only where something outside the folder imports
— and its rules for state, effects and memoization.

**Done when** every component reads as markup: it calls hooks (or the stack's equivalent) and
renders.

## 7. Data and states

Replace the in-memory state with the project's data layer on the operations from step 3 — its
data-fetching library, cache invalidation and API error display, the way neighbouring
features do it. The loading, empty and error states now come from real conditions, and each
must look like the state reviewers approved behind its review link. A state the mock never
showed (a partial failure, a stale-data banner) is a visible change: show it to the user
first.

**Done when** nothing imports the `mockData` module, it and the `scenario` URL parameter are
deleted, and every approved state is reachable from real conditions.

## 8. Text

Move every literal into the project's i18n system, in every locale the app ships. The wording
approved in the mock is the primary-language translation. If the project has no i18n, skip
this step and say so in the report.

**Done when** every user-visible string in the folder — including `aria-label`, `title` and
placeholder props — goes through the translation function.

## 9. Tests

Follow the project's testing conventions; when the project has no test runner, ask the user
before adding one. Cover what the mock proved matters: the flag gate (off renders not-found,
on renders the page), the access rules from step 4, the utilities and hooks extracted in
step 6, the approved states, and the interactions the reviewers clicked through. Run the test
files you wrote.

**Done when** those files pass and each test would fail if the behaviour it names broke.

## 10. Parity, review and hand-off

1. **Parity.** Take the same screenshots as step 2 from the production code — reach each
   state through real conditions, test data or a mocked network in the dev setup — and compare
   each pair. Fix every difference, or show it to the user and record their decision. With no
   screenshots, give the user the list of screens and states to walk through against the mock.
2. **Review.** Review the feature folder against the project's design and code-review
   standards and fix what the review finds.
3. **Hand-off.** Delete `MOCK.md`; move its _Decisions_ and _Open questions_ into the pull
   request description, along with who approved the mock. At commit time the project's quality
   gates apply (lint, type-check, tests, PR checklist).

**Done when** `MOCK.md`, the `mockData` module and both review parameters are gone, the flag
and gate are still in place, every screenshot pair matches or has a recorded decision, and the
report names any gap from steps 3–4 and any visible change the user approved.
