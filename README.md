# mockship

![ui-to-mock builds a flag-gated clickable mock in your real app; after the team approves it, mock-to-ui ships it as production code with the same look and flow](assets/hero.png)

Two [Agent Skills](https://agentskills.io) for UI work in an existing app. The first builds a
quick mock inside the app so people can click through it and approve it. The second turns the
approved mock into production code.

- [`ui-to-mock`](skills/ui-to-mock/SKILL.md) builds a clickable mock of a screen or flow inside your existing app, using its real routes, layout and theme with fake in-memory data, behind a feature flag that defaults off. It writes no tests, translations or API calls, and leaves a `MOCK.md` hand-off.
- [`mock-to-ui`](skills/mock-to-ui/SKILL.md) takes an approved mock (a feature folder with a `MOCK.md`) and turns it into production code: real API operations, shared components, translations, loading, empty and error states, and tests. What the user approved stays the same.

They work with any frontend stack that has routes, a component library or theme, and ideally a
feature-flag system. The agent reads your project's own conventions (`AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, other installed skills) and follows them. The skills only add the rules
that make a mock a mock.

## Why

A prototype built in a separate design tool drifts away from the real app. A prototype built
straight in the app tends to turn into half-finished production code. mockship keeps the two
phases apart:

- The mock is cheap and contained. All its code lives in one feature folder. Shared code is
  read-only, and anything that nearly fits is copied into the folder and listed as a _stand-in_.
  The only edits outside the folder are the flag, the routes, and an entry point if you ask for
  one.
- The mock ships dark. A feature flag that defaults off gates every mock page, so you can merge
  a mock and demo it in any environment without users seeing it.
- The mock is the spec. `mock-to-ui` changes how the feature is built, not what a user sees.
  When a production constraint would change the UI, the agent stops and asks.
- Missing API operations stop the work. If the approved screens need an operation the backend
  does not have, `mock-to-ui` lists it and waits. It does not hand-write a request around your
  API layer.

## Install

### Claude Code (plugin marketplace)

```bash
claude plugin marketplace add marcellefter/mockship
```

```bash
claude plugin install mockship@mockship
```

Or, inside a session: `/plugin marketplace add marcellefter/mockship`, then `/plugin install
mockship@mockship`. The skills are then available as `/mockship:ui-to-mock` and
`/mockship:mock-to-ui`, and the agent also uses them on its own when a request matches.

### Any agent that supports Agent Skills (skills CLI)

```bash
npx skills add marcellefter/mockship
```

### Manually

Copy the folders under [`skills/`](skills) into your agent's skills directory. For Claude Code
that is `.claude/skills/` in a project, or `~/.claude/skills/` for every project. Some other
agents read `.agents/skills/`.

```bash
git clone https://github.com/marcellefter/mockship.git
```

```bash
cp -r mockship/skills/ui-to-mock mockship/skills/mock-to-ui .claude/skills/
```

## Usage

### 1. Build the mock

Ask for it in plain words, or hand over a design file or screenshot:

> Mock an Invoices list and an invoice detail page so product can click through it before the
> backend exists.

The agent then:

1. Works out the stack (framework, router, design system, flags, data layer, i18n, tests,
   permissions) and lists the screens, the flow between them, the states each one needs and
   who sees what. It asks about anything the request leaves open before building.
2. Adds the flag first, the same way your project declares other flags, defaulting to off. If
   your project has no flag mechanism, it offers a build-time env var, a development-only route
   or a development URL switch and lets you pick.
3. Builds the screens in one feature folder. Each page is a real route; tabs, modals, filters
   and form submits work; and writes change in-memory data seeded from a `mockData` module.
   Styling comes from your component library and theme tokens, and the layout matches the
   closest existing page in the app.
4. Makes every state reachable from a URL (`?scenario=empty`, `?scenario=error`,
   `?scenario=loading`, and `?role=viewer` when access differs), so reviewers sign off on
   those too.
5. Keeps `MOCK.md` up to date in the feature folder: status, flag, stack, screens and flow, a
   review link per screen and state, access, touchpoints, local stand-ins, assumed data,
   decisions and open questions.
6. Runs the project's type-check and two scripts. One checks that only the feature folder and
   the listed touchpoints changed. The other checks for literal colours, sizes and raw palette
   classes; token idioms such as `hsl(var(--x))`, breakpoints and 1px borders are allowed. It
   then reports the review links.

Changing an approved mock puts it back to draft. Abandoning a mock undoes every touchpoint it
listed. Several mocks can be in progress at once. With a file-based router (Next.js,
SvelteKit, Nuxt, Remix), the route files stay thin and import from the feature folder.

### 2. Review and sign off

The agent asks how reviewers will reach the mock (a preview deployment with the flag on, flag
targeting for named accounts, or a walkthrough) and records the answer. Feedback goes into the
mock and the _Decisions_ log. Only you can mark it approved, and you have to say who approved
it:

> Ana Popescu from product signed off on the Invoices mock today.

The agent records that as `Status: approved by Ana Popescu on 2026-10-27`.

### 3. Ship it

> Ana approved the Invoices mock. Make it production-ready.

The agent works through ten steps, each with its own finish line:

1. Confirm the sign-off and list every file in the feature folder.
2. Screenshot every review link as a baseline.
3. Map every read and write to a real API operation.
4. Map _Access_ onto your permission checks.
5. Resolve each stand-in against your shared components.
6. Restructure the code to your conventions.
7. Swap the in-memory data for your data layer.
8. Move the copy into i18n.
9. Write and run tests.
10. Compare screenshots against the baseline and hand off.

It keeps a _Promotion_ record in `MOCK.md`, so a later session can pick up where this one
stopped. When an API operation or permission is missing, it stops and gives you a drafted
contract for the API owner. At the end `MOCK.md`, `mockData` and the review parameters are
deleted. The flag and gate stay, so turning the feature on remains the product owner's call.

## Repository layout

```
mockship/
├── .claude-plugin/marketplace.json   # Claude Code marketplace + plugin definition
├── skills/
│   ├── ui-to-mock/
│   │   ├── SKILL.md
│   │   ├── assets/MOCK.template.md
│   │   ├── references/               # stack discovery, flag options and gates per framework
│   │   ├── scripts/                  # check-boundary.sh, check-tokens.sh
│   │   └── evals/                    # test cases (claude plugin eval format)
│   └── mock-to-ui/
│       ├── SKILL.md
│       └── evals/
├── examples/
│   ├── sample-app/                   # React + Vite app the evals run against
│   ├── overlays/                     # layers on the sample app: no flags, a finished mock, draft status
│   ├── scaffold.sh                   # sets up the sample app for an eval run
│   ├── test-scripts.sh               # tests for the check scripts
│   └── test-fixtures.sh              # sets up every eval case and checks it
├── assets/                           # README image and its source
├── .github/workflows/ci.yml
├── CHANGELOG.md
└── LICENSE
```

Each skill follows the [Agent Skills specification](https://agentskills.io/specification): a
folder whose `SKILL.md` has `name` and `description` frontmatter, with longer material in
`references/`, `assets/` and `scripts/` that the agent loads only when needed.

## Testing

CI validates the marketplace manifest and both skills against the spec, installs them with
`npx skills add`, tests the check scripts, builds and tests the sample app, and sets up every
eval case to check that it type-checks and that each mock in it passes the skill's own checks.

The eval cases test the skills themselves. Each one runs a real agent against the sample app,
once with the skill and once without. With Claude Code 2.1.269 or later, from a skill folder:

```bash
npm ci --prefix examples/sample-app
```

```bash
cd skills/ui-to-mock && claude plugin eval . --scaffold --allow-tools Write,Edit,Bash --runs 1
```

These are real model runs that you pay for. Each case sets up a fresh copy of the sample app
and can take several minutes.

Latest results: version 1.3.0, Claude Opus 5.5, one run per case, 2026-10-28.

| Skill | Case | With skill | Without |
| --- | --- | --- | --- |
| ui-to-mock | builds-flagged-invoices-mock | 1.00 | 0.27 |
| ui-to-mock | offers-options-when-no-flag-system | 1.00 | 0.25 |
| ui-to-mock | keeps-shared-badge-read-only | 1.00 | 0.75 |
| ui-to-mock | keeps-draft-until-approver-named | 1.00 | 1.00 |
| ui-to-mock | ignores-test-double-requests | 1.00 | 1.00 |
| mock-to-ui | asks-for-sign-off-when-draft | 1.00 | 0.00 |
| mock-to-ui | promotes-approved-mock-end-to-end | 1.00 | 0.89 |
| mock-to-ui | stops-on-missing-api-operations | 1.00 | 0.83 |
| mock-to-ui | extends-shared-badge-for-stand-in | 1.00 | 1.00 |
| mock-to-ui | edits-draft-mock-without-promoting | 1.00 | 1.00 |

`ignores-test-double-requests` and `edits-draft-mock-without-promoting` check that the skill
stays out of the way when it should, so a tie with the baseline is the expected result.
`extends-shared-badge-for-stand-in` also ties and is kept to catch regressions.
`keeps-draft-until-approver-named` scored 0.50 without the skill on 1.2; in this run the agent
without the skill also kept the mock in draft and asked who approved it. One run per case is
noisy, so treat a single tie or gap with care.

In `promotes-approved-mock-end-to-end` both runs finished the promotion: real API data,
`useCan` access checks, the shared badge extended, both locales, tests, type-check and tests
passing, and the flag still off. The difference is the hand-off. With the skill the agent moved
the decisions into a pull request description and deleted `MOCK.md`. Without it the agent kept
`MOCK.md` and added its decisions there.

Graders read the files a run leaves behind wherever they can, because a judge model only sees
the first and last twelve messages of a long run.

## Adapting

The skills leave anything specific to your stack to your project. To make them sharper for one
codebase, fork them and write the specifics in: where feature folders live, which flag helper
to use, your design-system skill, your data-fetching library. Keep the core rules: flag first,
shared code read-only, the `MOCK.md` hand-off, the mock is the spec, and missing API
operations stop the work.

## License

[MIT](LICENSE)
