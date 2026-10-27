# Flags and gates

## No flag mechanism

When the project has no way to switch features, offer the user these options and let them
pick. Each one keeps the mock off by default.

| Option | How it works | Good for |
| --- | --- | --- |
| **Build-time env var** | `VITE_FEATURE_INVOICES=true` (Vite), `NEXT_PUBLIC_FEATURE_INVOICES=true` (Next.js), `NG_APP_…` / `environment.ts` (Angular). Unset means off. | Most apps; preview deployments can set it per environment. |
| **Development-only route** | Register the mock routes only when `import.meta.env.DEV` (or `process.env.NODE_ENV !== 'production'`). | Mocks reviewed locally only. Production builds never contain the routes. |
| **Development URL switch** | In development builds only, `?ff=invoices` sets a `localStorage` key the gate reads. Ignored in production builds. | Letting a reviewer toggle it on a dev server without restarting. |

Only the env var can ship. The two development-only switches suit a mock reviewed on a dev
server; before the feature ships, `mock-to-ui` swaps them for a shippable switch (the env var
or a flag service), so say that when you offer them.

Put the chosen switch in one small module (for example `src/flags.ts` exporting
`isInvoicesEnabled()`), record it as a touchpoint, and recommend a real flag service to the
user when the feature needs per-user rollout.

## The gate

One component in the feature folder wraps every mock page:
flags not ready → the app's loading element; flag off → the app's not-found element; flag on →
the page. Use the app's own loading and not-found elements, not new ones.

### React (React Router)

```tsx
export function InvoicesGate({ children }: { children: React.ReactNode }) {
  const ready = useFlagsReady();          // omit if flags are synchronous
  const enabled = useFlag(INVOICES_FLAG);
  if (!ready) return <PageLoader />;
  if (!enabled) return <NotFoundPage />;
  return <>{children}</>;
}

// routes
{ path: '/invoices', element: <InvoicesGate><InvoiceListPage /></InvoicesGate> }
```

### Vue (Vue Router)

```vue
<script setup lang="ts">
const { ready, enabled } = useFlag('invoices');
</script>

<template>
  <PageLoader v-if="!ready" />
  <NotFoundPage v-else-if="!enabled" />
  <slot v-else />
</template>
```

### SvelteKit

```svelte
<!-- src/routes/invoices/+layout.svelte -->
<script lang="ts">
  import { flags } from '$lib/flags';
  import NotFound from '$lib/NotFound.svelte';
  let { children } = $props();
</script>

{#if $flags.invoices}
  {@render children()}
{:else}
  <NotFound />
{/if}
```

### Angular

```ts
export const invoicesGuard: CanMatchFn = () => inject(FlagService).isEnabled('invoices');

// routes: when the guard fails, the router falls through to the app's '**' not-found route
{ path: 'invoices', canMatch: [invoicesGuard], loadComponent: () => import('./invoice-list.page') }
```

## Reading the review parameters

`scenario` (and `role`, when access differs) come from the URL so reviewers can open each state
from a link. Read them in one helper in the feature folder:

```ts
// React Router
const [params] = useSearchParams();
const scenario = params.get('scenario') ?? 'populated';
```

Vue: `useRoute().query.scenario`. SvelteKit: `page.url.searchParams.get('scenario')`.
Angular: `inject(ActivatedRoute).snapshot.queryParamMap.get('scenario')`.

For `loading`, render the loading state indefinitely rather than on a timer, so reviewers can
look at it.
