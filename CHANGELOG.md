# Changelog

All notable changes to mockship. Versions follow [Semantic Versioning](https://semver.org).

## 1.2.0 — 2026-10-27

From an independent review aimed at real-world codebases.

### Skills

- **Token check fits real codebases**: colour functions wrapping a token (`hsl(var(--x))`),
  `@media`/`@container`/`@supports` lines and 0px/1px hairlines no longer count; a
  `.mockship-allow` file holds project-wide idioms; `--advisory` reports without failing for
  projects with no token system.
- **File-based routers**: route files are thin touchpoints that import from the feature folder,
  and a touchpoint ending in `/` covers a whole route folder. New Next.js App Router gate; the
  SvelteKit gate moves into the feature folder.
- **Lifecycle**: a visible change after approval puts the mock back to draft; abandoning a mock
  undoes every touchpoint; several mocks can be in flight, and the boundary check reports
  another mock's files instead of failing them. `mock-to-ui` keeps a _Promotion_ record in
  `MOCK.md` and resumes from it.
- **Triggering**: `ui-to-mock` is not for test doubles, API/network mocking or Storybook
  fixtures; changes to a draft mock belong to `ui-to-mock`, and `mock-to-ui` treats them as
  mock work, not promotion.
- **Boundary check on the base branch** refuses to run without the commit the mock started
  from, instead of passing because committed files look like history.
- **Type-check before reporting**: a mock must compile; `mock-to-ui` finishes with type-check
  and tests passing.
- Approval needs a named approver and a date (`approved — <who>, <YYYY-MM-DD>`).

### Evals

- Tempting prompts for the cases that scored the same with and without the skill ("it's
  approved, go ahead" with no approver), and the fixture no longer hints the answer.
- New cases: a test-double request that must not fire `ui-to-mock`, a copy edit to a draft
  mock that must not start a promotion, and a full promotion on a backend-complete fixture.
- File-content, tool-use and file-existence graders where a judge model is not needed.

## 1.1.2 — 2026-10-27

- `check-tokens.sh`: on Linux (GNU grep) the stylesheet scan also read code files, so copy such
  as "Invoice #1042" failed there. File filters now come before the exclusions.

## 1.1.1 — 2026-10-27

Fixes from a standards and spec review of 1.1.0, and from the first full eval run.

### Skills

- `check-boundary.sh` fails loudly (exit 2) outside a git repository, on an unknown base ref
  and on any git error, instead of printing OK; only paths listed under _Touchpoints_ count;
  non-ASCII paths match.
- `check-tokens.sh` reports unreadable files as an error, and in code only flags a hex value
  in a value position, so copy such as "Invoice #1042" passes without a marker.
- `MOCK.md` template: _Review links_ gets a Role column and write-failure rows; _Screens and
  flow_ records the design source and deviations.
- `mock-to-ui` rebuilds `MOCK.md` with the _Review_ section, and swaps a development-only flag
  switch for a shippable one before shipping.
- `ui-to-mock` states that skipping tests and translations deliberately overrides a project
  rule requiring them.

### Repository

- Eval fixture rebuilt to follow the 1.1 rules (write-error and in-flight states, honest width
  literals) and split into layers: a finished mock plus a draft-status layer.
- New eval case `keeps-draft-until-approver-named`; the build case checks flag-first order and
  write states again.
- Eval setup copies the sample app's dependencies in, since eval sandboxes have no network.
- CI pins Claude Code, skills-ref and the skills CLI, installs both skills with
  `npx skills add`, and sets up every eval case to check it typechecks and passes the skill's
  checks.
- README states exactly what the end-to-end run found.

## 1.1.0 — 2026-10-27

### ui-to-mock

- **Intake step**: screens, flow, interactions, states, access and design source are listed
  before building; open questions are asked first.
- **Stack discovery** reference (`references/stack-discovery.md`), recorded in `MOCK.md`.
- **Projects without feature flags**: offers a build-time env var, a development-only route or
  a development URL switch instead of stopping (`references/gates.md`).
- **Gate examples** for React, Vue, SvelteKit and Angular.
- **Reviewable states**: every screen renders empty, error and loading from a `scenario` URL
  parameter, writes can be made to fail with `?scenario=write-error` and show their in-flight
  state, and roles switch with a `role` parameter, so reviewers approve all of them.
- **Honest literals**: a value the theme has no token for is copied from the neighbouring page
  with a `mockship-allow` marker and listed as a stand-in, never disguised as token arithmetic.
- **Review and sign-off**: how reviewers reach the mock, review links per screen and state, a
  decisions log, and an approval status only the user can set.
- **`MOCK.md` template** (`assets/MOCK.template.md`) with Status, Stack, Review links, Access
  and Decisions sections.
- **Check scripts**: `check-boundary.sh` finds the base branch itself and checks touchpoints
  against `MOCK.md`; `check-tokens.sh` also catches Tailwind palette classes and arbitrary
  values, skips `mockData`, and honours a `mockship-allow` marker.

### mock-to-ui

- **Sign-off check** before any change; never assumes approval.
- **Baseline screenshots** of every review link, compared against the result at the end.
- **API gaps** come with a drafted contract for the API owner; the Access step may run while
  waiting, everything after it waits.
- **Access step** maps `MOCK.md` → _Access_ onto the app's permission checks.
- **States** must match the approved scenarios; new states are shown to the user first.

### Repository

- Evals in the `claude plugin eval` case-folder format, run against a sample React app.
- Both skills tested end to end on the sample app by fresh agents with only the skill to go
  on: mock built, reviewed and approved, gaps drafted and closed, shipped with 28 new tests and
  13 of 13 review states matching the approved mock.
- Sample app fixture (`examples/sample-app`) and eval scaffold.
- CI: marketplace and Agent Skills validation, check-script tests, sample app checks.

## 1.0.0 — 2026-10-27

- First release: `ui-to-mock` and `mock-to-ui`, extracted and generalised from an internal
  monorepo workflow.
