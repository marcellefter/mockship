---
name: mock-to-ui
description: Promote an approved UI mock built with ui-to-mock into production code (real API data, access checks, translations, tests, shared components and the project's conventions) and prove it still looks and flows like the approved mock. Use when a mock has been signed off and must ship, or to resume a promotion recorded in a MOCK.md. Not for changing a mock that is still in review (Status draft); that is ui-to-mock.
license: MIT
metadata:
  author: marcellefter
  version: "1.3.1"
---

# Mock to UI

The input is a feature folder built by the `ui-to-mock` skill. It is clickable and
flag-gated, uses fake data with states you can open from a URL, has plain-text copy and no
tests, and comes with a `MOCK.md` listing everything it touched. The output is the same
feature as production code.

**The mock is the spec.** Layout, flow, copy and every state behind a review link were
approved as they are. The steps below change how the feature is built, not what a user sees.
When a production constraint forces a visible change (the API cannot sort that column, or a
state the mock never showed), show it to the user and let them decide.

**The flag stays.** The feature keeps shipping dark behind the mock's flag and gate. Turning it
on, and later removing it, is a rollout decision for the product owner, outside this skill.

Each step defers to the project's own conventions for its subject: `AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, and any installed skill that covers it (API usage, components, i18n,
testing, design review). _Stack_ in `MOCK.md` names the libraries. This skill sets the order
and the finish line for each step.

## Keep a record

Promotion stops for decisions and can span sessions, so keep _Promotion_ in `MOCK.md` current.
Write one line per step (`done`, `waiting: <what>` or `skipped: <why>`), where the baseline
screenshots are, and every gap you drafted with its status. When **resuming**, read it first
and carry on from the first step that is not done. Don't redo a finished step from memory. If
the baseline folder is gone, say so. Step 10 then becomes a walkthrough against the mock's
review links, as long as the mock is still in git history.

## 1. Inventory and sign-off

Read `MOCK.md`, then every file in the feature folder.

- **Not a promotion?** When the user asks for a change to the mock itself (copy, a moved
  button, a new state), that is mock work. Make it the way `ui-to-mock` does, in the feature
  folder with literals and fixtures. A visible change to an approved mock puts _Status_ back
  to `draft`, which needs sign-off again before promotion continues.
- **Sign-off.** _Status_ must read `approved by <who> on <YYYY-MM-DD>`. If it still reads
  `draft`, ask the user who approved the mock and when, and record it before changing any
  code. "It's approved" without a name is not enough. Never assume approval.
- **No `MOCK.md`** (a mock built without `ui-to-mock`): rebuild one from the diff against the
  branch's merge base with these sections: Status, Flag, Stack, Screens and flow, Review
  links, Review, Access, Touchpoints, Local stand-ins, Data the screens assume, Decisions,
  Open questions, Promotion. Then confirm the gaps in it with the user.
- **A development-only switch** (a route or URL switch that only exists in development
  builds) cannot ship. Ask the user which shippable switch replaces it, a build-time env var
  or a flag service, and make the swap part of this work.

**Done when** the mock is recorded as approved, the flag can ship, every file is classed as
page, component, local stand-in, data, review helper or gate, and every touchpoint in
`MOCK.md` is confirmed present in the code.

## 2. Baseline

With the flag on, open every row of _Review links_ and save a screenshot of each (every
screen in every state and role) to a folder **outside the repository**, such as a temp or
scratch directory. Use whatever browser automation you have: a browser tool, Playwright, or
headless Chrome (`--headless --screenshot`). Step 10 compares the result against these.

**Done when** there is one screenshot per review link. If you have no way to take screenshots,
say so now. Step 10 then becomes a walkthrough the user does against the mock, and the report
must say the comparison was manual.

## 3. Contract

For every entry under _Data the screens assume_ and every write the screens perform, find the
real operation the frontend will call: a generated API client operation, an existing service
function, a GraphQL query or mutation.

**Done when** each read and write maps to a named operation. Any that does not is a **gap**.
For each gap, draft the missing contract from the mock: the operation, a suggested method and
path, request fields and response fields taken from the `mockData` types, and the screen that
needs it. Give the drafts to the user for the API owner, and **stop** until the user says how
to proceed. Step 4 (Access) may still run while you wait. Steps 5 onward wait, because the
answers can change what ships. Only the backend closes a gap. Don't hand-write a request
around the project's API layer or edit a generated client.

## 4. Access

Map every line under _Access_ onto the project's permission mechanism (route guards, a
`can()` helper, role checks) so each screen and action shows exactly for the roles the mock
showed it to. A role or permission the app does not have is a gap: report it as in step 3 and
stop. When _Access_ says everyone sees everything, confirm that against the routes the feature
sits under and move on.

**Done when** every _Access_ line is enforced by real checks, and the mock's `role` URL
parameter is gone.

## 5. Reuse

Walk _Local stand-ins_ and then every component in the folder, and resolve each one:

- **An existing shared or app component already does it.** Use that and delete the local one.
- **It is a variant of a shared component.** Extend the shared component in place, keep its
  current callers unchanged, and add the stories, docs or tests the shared code expects.
- **It is new.** Keep it in the feature. It moves to shared code only when a second feature
  or app needs it.

**Done when** every stand-in in `MOCK.md` has one of those three outcomes, and no feature file
duplicates rules from a shared component or the theme.

## 6. Structure

Apply the project's component conventions in full: when to split a component, where hooks and
utilities are extracted to, barrel files only where something outside the folder imports, and
its rules for state, effects and memoization.

**Done when** every component reads as markup: it calls hooks (or the stack's equivalent) and
renders.

## 7. Data and states

Replace the in-memory state with the project's data layer on the operations from step 3. Use
its data-fetching library, cache invalidation and API error display the way neighbouring
features do. The loading, empty and error states now come from real conditions, and each
must look like the state reviewers approved behind its review link. A state the mock never
showed (a partial failure, a stale-data banner) is a visible change, so show it to the user
first.

**Done when** nothing imports the `mockData` module, it and the `scenario` URL parameter are
deleted, and every approved state is reachable from real conditions.

## 8. Text

Move every literal into the project's i18n system, in every locale the app ships. The wording
approved in the mock is the primary-language translation. If the project has no i18n, skip
this step and say so in the report.

**Done when** every user-visible string in the folder, including `aria-label`, `title` and
placeholder props, goes through the translation function.

## 9. Tests

Follow the project's testing conventions. When the project has no test runner, ask the user
before adding one. Cover what the mock proved matters: the flag gate (off renders not-found,
on renders the page), the access rules from step 4, the utilities and hooks extracted in
step 6, the approved states, and the interactions the reviewers clicked through. Run the test
files you wrote.

**Done when** those files pass and each test would fail if the behaviour it names broke.

## 10. Parity, review and hand-off

1. **Parity.** Take the same screenshots as step 2 from the production code, reaching each
   state through real conditions, test data or a mocked network in the dev setup, and compare
   each pair. Fix every difference, or show it to the user and record their decision. With no
   screenshots, give the user the list of screens and states to walk through against the mock.
2. **Review.** Review the feature folder against the project's design and code-review
   standards and fix what the review finds.
3. **Hand-off.** Delete `MOCK.md`. Move its _Decisions_ and _Open questions_ into the pull
   request description, along with who approved the mock. At commit time the project's quality
   gates apply (lint, type-check, tests, PR checklist).

**Done when** the project's type-check and tests pass, `MOCK.md`, the `mockData` module and
both review parameters are gone, the flag and gate are still in place, every screenshot pair
matches or has a recorded decision, and the report names any gap from steps 3 and 4 and any
visible change the user approved.
