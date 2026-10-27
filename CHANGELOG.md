# Changelog

All notable changes to mockship. Versions follow [Semantic Versioning](https://semver.org).

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
