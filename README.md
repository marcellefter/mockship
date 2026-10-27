# mockship

![mockship — ui-to-mock builds a flag-gated clickable mock in your real app; after the team approves it, mock-to-ui ships it as production code with the same look and flow](assets/hero.png)

**Mock it, approve it, ship it.** Two [Agent Skills](https://agentskills.io) that split UI work
into a fast, throwaway-feeling mock that lives in your real app, and a disciplined promotion of
that mock into production code once it is approved.

| Skill | What it does |
| --- | --- |
| [`ui-to-mock`](skills/ui-to-mock/SKILL.md) | Builds a clickable mock of a screen or flow inside your existing app — real routes, real layout, real theme, fake in-memory data — behind a feature flag that defaults off. No tests, no i18n, no API calls. Writes a `MOCK.md` hand-off. |
| [`mock-to-ui`](skills/mock-to-ui/SKILL.md) | Takes an approved mock (a feature folder with a `MOCK.md`) and turns it into production code: real API operations, shared components, translations, loading/empty/error states and tests — without changing what the user approved. |

They work with any frontend stack that has routes, a component library or theme, and ideally a
feature-flag system. The agent reads your project's own conventions (`AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, other installed skills) and follows them; the skills only add the rules that
make a mock a mock.

## Why

Clickable prototypes built in a separate tool drift from the real app, and prototypes built
straight in the app tend to grow into half-finished production code. mockship keeps the two
phases apart:

- **The mock is cheap and contained.** All code lives in one feature folder. Shared code is
  read-only; anything that nearly fits is copied locally and listed as a _stand-in_. The only
  edits outside the folder are the flag, the routes, and an entry point if you ask for one.
- **The mock ships dark.** A feature flag that defaults off gates every mock page, so a mock can
  be merged and demoed on any environment without users seeing it.
- **The mock is the spec.** `mock-to-ui` changes how the feature is built, never what a user
  sees. When a production constraint would change the UI, the agent stops and asks.
- **Gaps stop the line.** If the approved screens need an API operation that does not exist,
  `mock-to-ui` lists the gap and waits — it never hand-writes a request around your API layer.

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
`/mockship:mock-to-ui`, and the agent also picks them up on its own when a request matches.

### Any agent that supports Agent Skills (skills CLI)

```bash
npx skills add marcellefter/mockship
```

### Manually

Copy the folders under [`skills/`](skills) into your agent's skills directory — for example
`.claude/skills/` in a project (or `~/.claude/skills/` for every project), or `.agents/skills/`
for agents that read that path:

```bash
git clone https://github.com/marcellefter/mockship.git
```

```bash
cp -r mockship/skills/ui-to-mock mockship/skills/mock-to-ui .claude/skills/
```

## Usage

### 1. Build the mock

Ask for it in plain words:

> Mock an Invoices list and an invoice detail page so product can click through it before the
> backend exists.

The agent will:

1. **Add the flag first**, the same way your project declares other flags, defaulting to off.
   If your project has no feature-flag mechanism it stops and asks where the flag should go.
2. **Build the screens** in one feature folder: each page is a real route, tabs/modals/filters
   and form submits work, and writes change in-memory data seeded from a `mockData` module.
   Styling comes from your component library and theme tokens, and the layout matches the
   nearest similar page in the app.
3. **Write `MOCK.md`** at the feature root: the flag, every touchpoint outside the folder, the
   local stand-ins, the data the screens assume, and open questions.
4. **Check its own boundary** (only the feature folder and the listed touchpoints changed, no
   literal colours or pixel values) and report the route, the flag and how to turn it on
   locally.

Turn the flag on in your development environment and click through it with your reviewers.

### 2. Ship it

Once the mock is signed off:

> The Invoices mock is approved — make it production-ready.

The agent works through eight steps, each with a clear finish line: inventory the folder,
map every read and write to a real API operation (stopping on gaps), resolve each stand-in
against shared components, restructure to your conventions, swap the in-memory data for your
data layer with loading/empty/error states, move copy into i18n, write and run tests, then
review and hand off. `MOCK.md` and `mockData` are deleted; the flag and gate stay so rollout
remains the product owner's call.

## Repository layout

```
mockship/
├── .claude-plugin/
│   └── marketplace.json      # Claude Code marketplace + plugin definition
├── assets/
│   ├── hero.png              # README image
│   └── hero.html             # its source (render with headless Chrome)
├── skills/
│   ├── ui-to-mock/
│   │   ├── SKILL.md
│   │   └── evaluations.json  # example prompts and expected behaviour
│   └── mock-to-ui/
│       ├── SKILL.md
│       └── evaluations.json
├── LICENSE
└── README.md
```

Each skill follows the [Agent Skills specification](https://agentskills.io/specification): a
folder whose `SKILL.md` carries `name` and `description` frontmatter followed by the
instructions. `evaluations.json` lists test prompts with the behaviour a correct run shows —
useful when you adapt the skills to your codebase.

## Adapting

The skills deliberately defer to your project for anything stack-specific. If you want them
sharper for one codebase, fork and name the specifics: where feature folders live, the flag
helper to use, your design-system skill, your data-fetching library. Keep the core rules —
flag first, shared code read-only, `MOCK.md` hand-off, the mock is the spec, gaps stop the line.

## License

[MIT](LICENSE)
