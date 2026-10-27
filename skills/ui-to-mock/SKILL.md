---
name: ui-to-mock
description: Build a clickable UI mock of a screen or flow inside the real app — behind a feature flag that defaults off, with fake in-memory data, switchable empty/error/loading states, plain-text copy and no tests — and take it through review to sign-off. Use when asked to mock, prototype or click-through a page or feature in an existing frontend codebase before the backend or sign-off exists, including from a design file or screenshot, and to change, re-review or abandon such a mock (a feature folder whose MOCK.md says Status draft). Not for test doubles, mocking API calls or the network (MSW, jest.mock), or Storybook fixtures. Promoting an approved mock to production code is the mock-to-ui skill.
license: MIT
metadata:
  author: marcellefter
  version: "1.2.0"
---

# UI to mock

A **mock** is a clickable prototype that lives in the real app: real routes, real layout shell,
real theme, fake data. It exists so people can click through a flow and approve it before
anyone builds a backend. Two things matter — **speed** and **visual consistency** with the
rest of the app. Everything that makes code production-grade is deferred to the `mock-to-ui`
skill, which runs once the mock is approved.

Before starting, read the project's own agent and contributor docs (`AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, or similar). Where they set a convention — folder layout, naming, styling,
flags — follow it; this skill only adds the rules that make a mock a mock. Then work through
[references/stack-discovery.md](references/stack-discovery.md) so you know the framework,
router, design system, flag mechanism and data layer before writing a line.

## The boundary

All mock code lives in **one feature folder**, placed and named the way the project places
features (for example `src/features/<feature>/`, or `apps/<app>/src/features/<feature>/` in a
monorepo). If the project has no feature-folder convention, ask where it goes.

**Shared code is read-only.** Import any shared components, hooks, utilities and theme the
project's module boundaries allow, and use them as-is. When a shared piece nearly fits, build
the variant inside the mock folder and list it under _Local stand-ins_ in `MOCK.md`. The mock
never edits a file outside its folder, except these **touchpoints**, which are the complete
list:

| Touchpoint         | Where                                                                         |
| ------------------ | ----------------------------------------------------------------------------- |
| The flag           | wherever the project declares feature flags                                   |
| One route per page | the project's route table or router config                                    |
| An entry point     | a menu item or a link on an existing screen — only when the user asks for one |

**File-based routers** (Next.js `app/` or `pages/`, SvelteKit and Remix `routes/`, Nuxt
`pages/`) need their route files where the router looks for them. Those files are touchpoints:
keep each one thin — it imports the page and the gate from the feature folder and renders
them, nothing else — and list the route folder in `MOCK.md` as one touchpoint ending in `/`
(`src/routes/invoices/`). [references/gates.md](references/gates.md) shows the pattern for
Next.js and SvelteKit.

## 1. Intake

Turn the request into a list before building anything:

- **Screens** — every page, modal and drawer, each with a one-line purpose.
- **Flow** — how a user moves between them (`List → Detail`, `List → New invoice modal → List`).
- **Interactions** — filters, sorting, tabs, form submits, the writes each one performs.
- **States** — for every screen with data: populated, empty, error and loading are the
  default; add any the request names (permission denied, over limit). For every write: what
  its control shows while the write is in flight, and what the user sees when it fails.
- **Access** — whether different roles see different screens or actions. "Everyone sees
  everything" is a valid answer; write it down.
- **Source** — a design file, screenshot or sketch, if the user gave one. Match its layout and
  content using the project's components; record the source and anywhere you deviated, and
  why, under _Screens and flow_.

When the request leaves screens, flow or access open, ask before building. When it is
explicit, state the list and carry on. Copy
[assets/MOCK.template.md](assets/MOCK.template.md) to `MOCK.md` in the feature folder and fill
in _Status_ (`draft`), _Stack_, _Screens and flow_ and _Access_ now.

## 2. Flag first

Every mock ships dark, so the flag exists before the first screen does.

1. **The project has a flag mechanism** (a flags module, a service such as Unleash,
   LaunchDarkly, GrowthBook or Flagsmith, a config file): add the new flag exactly the way
   existing flags are added — same naming pattern, same helpers. **Its default is always off.**
2. **It has none:** do not invent one. Offer the user the options in
   [references/gates.md](references/gates.md) → "No flag mechanism" (a build-time environment
   variable, a development-only route, a development-only URL switch), let them pick, and
   record the choice in `MOCK.md`. It counts as a touchpoint.
3. Write one **gate** component in the mock folder and wrap **every** mock page in it: render
   the app's loading state until flags are resolved (if the flag client is asynchronous), then
   the page when the flag is on, otherwise the same not-found element the app renders for an
   unknown route. [references/gates.md](references/gates.md) has the gate in React, Vue,
   Svelte, Angular and the Next.js App Router.
4. Any entry point the user asked for renders only when the flag is on.

The off default keeps the mock invisible everywhere, including in a deployed environment where
the flag was never created in the flag service.

## 3. Build the screens

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

**States are reviewable.** Each screen reads a `scenario` URL parameter —
`?scenario=empty`, `?scenario=error`, `?scenario=loading`, plus any extra state from intake —
and renders that state from the fixtures; without the parameter it shows the populated state.
`?scenario=write-error` makes every write fail, so reviewers see the failure feedback, and
writes take a moment so the in-flight state (a disabled or busy control) is visible.
Build every state with the design system's own empty, error and loading patterns, because
reviewers approve these too and `mock-to-ui` reproduces them as approved. When intake found
that roles differ, a `role` URL parameter switches which screens and actions show. Both
parameters live only in the mock folder; `mock-to-ui` removes them.

**Copy** is plain string literals in the markup, in the app's primary language — no i18n
calls, no locale files. Casing and wording still follow the project's copy guidelines, if it
has any.

**Visual consistency** comes from two sources:

- **The design system.** Use the project's component library first, then its theme tokens
  (CSS variables, a theme object, Tailwind theme classes, design tokens) for anything custom.
  Every colour, size, radius and spacing is a token — never a literal. When the theme has no
  token for a value the neighbouring page hard-codes (a page max-width, say), copy the
  neighbour's literal with a `mockship-allow` comment and list it under _Local stand-ins_ so
  `mock-to-ui` turns it into a token; never disguise it as arithmetic on unrelated tokens. If
  the project has a design skill or style guide, load it before the first screen.
- **Match the neighbour.** Find the nearest real page in the same app with a similar shape
  (list, detail, settings, wizard) and reuse its page shell, header, toolbar and table
  components rather than composing new ones.

**Structure**: follow the project's component placement and naming conventions — file and
folder casing, where styles live, export style, callback naming. It costs nothing now and
saves `mock-to-ui` a move. Leave splitting large components, extracting hooks and utilities,
and barrel files for `mock-to-ui`.

## What mock-to-ui owns

The mock leaves these to `mock-to-ui`, so they stay out of the mock even when they feel quick:
test files, translation keys, API clients and data fetching, API error handling, real
permission checks, and any edit to shared code. This deliberately overrides a project rule
that every change carries tests or translations — the mock is thrown away or rebuilt by
`mock-to-ui` — so say so in the report when the project has such a rule. Running lint or tests
while iterating is likewise out. The project's **type-check is not**: a mock that does not
compile breaks the dev server on some stacks and the team's CI once merged, so run it before
reporting (see _Done when_). The project's other quality gates apply unchanged when the user
asks to commit, because a merged mock is still merged code.

## 4. Review and sign-off

A mock is only useful once the people who approve it can click through it. Ask the user how
reviewers will reach it, and record the answer under _Review_ in `MOCK.md`:

- **A preview or staging deployment** with the flag switched on in that environment only.
- **Flag targeting** — on in production or staging for the named reviewers' accounts only,
  when the flag service supports it.
- **A walkthrough** — the user demos it locally, or you capture screenshots of every screen
  and state from the _Review links_ when a browser tool is available.

Fill _Review links_ with one URL per screen and state, so reviewers can open each without
hunting. When feedback comes back, change the mock, log each change under _Decisions_, and
move answered items out of _Open questions_.

**Never mark a mock approved yourself.** Set _Status_ to `approved — <who>, <YYYY-MM-DD>` —
exactly that form, with an em dash — only when the user names who signed it off. "Product
approved it" without a name is not enough: keep _Status_ at `draft`, do any other work the
user asked for, and end your reply with the question "Who approved the mock, and on what
date?" so the approval can be recorded.

## Changing, pausing or abandoning a mock

- **A visible change after approval** — new copy, a moved button, a dropped action — puts
  _Status_ back to `draft` and needs sign-off again. Log it under _Decisions_. A change nobody
  can see (a renamed variable) keeps the approval.
- **Several mocks at once** each get their own feature folder and `MOCK.md`. Two mocks may
  share a touchpoint file (the flags module, the route table); both list it. The boundary check
  reports another mock's files without failing.
- **Abandoning a mock** means removing the feature folder and undoing every touchpoint listed
  in `MOCK.md` — the flag, the routes, any entry point. Afterwards the diff against the base
  branch shows nothing from the mock; confirm that with `git diff` before reporting.

## 5. Keep MOCK.md current

`MOCK.md` is the hand-off to `mock-to-ui`. Every touchpoint, stand-in, assumed field, review
link, decision and open question goes in as soon as it exists. The template shows each section.

## Done when

- Every screen from intake is reachable by clicking from the first mock page with the flag on,
  every interaction works against the in-memory data, and every state from intake renders from
  its review link.
- With the flag off, every mock route renders the not-found element and no entry point shows.
  Check the "on" path through the project's local override; if that needs a restart you
  cannot do, flip the default temporarily, then put it back to off and check the "off" path
  again.
- The project's **type-check** passes (`tsc`, `vue-tsc`, `svelte-check`, `ng build` — whatever
  the project runs). Fix errors in the mock; report any that were there before the mock.
- The **boundary check** passes — only the feature folder and the touchpoints listed in
  `MOCK.md` changed. It finds the base branch itself; on the base branch, or when it cannot
  find one, pass the commit the mock started from as a second argument:

  ```bash
  bash <this-skill>/scripts/check-boundary.sh <path-to-feature-folder>
  ```

- The **token check** passes — no literal colour, size or raw palette class in the feature
  folder outside `mockData` and Markdown. Token idioms (`hsl(var(--primary))`), `@media`
  breakpoints, 1px hairlines and copy such as "Invoice #1042" pass. Excuse a single line that
  is not styling with a `mockship-allow` comment, and an idiom the whole project uses with a
  pattern in a `.mockship-allow` file at the repository root (one regex per line). When stack
  discovery found no token system at all, run it with `--advisory` and say so in the report:

  ```bash
  bash <this-skill>/scripts/check-tokens.sh <path-to-feature-folder>
  ```

`<this-skill>` is the folder this `SKILL.md` is in. Report the route URL, the flag and how to
switch it on locally, the review links, and the `MOCK.md` stand-ins and open questions. If you
could not open the mock in a browser, say so.
