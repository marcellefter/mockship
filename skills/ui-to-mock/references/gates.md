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

One component in the feature folder wraps every mock page. While flags are not ready it
renders the app's loading element, with the flag off the app's not-found element, and with the
flag on the page. Use the app's own loading and not-found elements, not new ones.

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

The route files are touchpoints; the gate lives in the feature folder.

```svelte
<!-- src/lib/features/invoices/InvoicesGate.svelte -->
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

```svelte
<!-- src/routes/invoices/+layout.svelte is a touchpoint: it imports and renders, nothing else -->
<script lang="ts">
  import InvoicesGate from '$lib/features/invoices/InvoicesGate.svelte';
  let { children } = $props();
</script>

<InvoicesGate>{@render children()}</InvoicesGate>
```

### Next.js (App Router)

Gate on the server, so a disabled mock never ships its markup, and let `notFound()` render the
app's own `not-found.tsx`. Pass `scenario` (and `role`) down from the page's `searchParams`
rather than calling `useSearchParams` in client components, which would need a Suspense
boundary.

```tsx
// src/features/invoices/InvoicesGate.tsx
import { notFound } from 'next/navigation';
import { isFlagOn } from '@/flags';

export async function InvoicesGate({ children }: { children: React.ReactNode }) {
  if (!(await isFlagOn('invoices'))) notFound();
  return <>{children}</>;
}
```

```tsx
// app/invoices/page.tsx is a touchpoint: it imports and renders, nothing else
import { InvoiceListPage, InvoicesGate } from '@/features/invoices';

export default async function Page({ searchParams }: { searchParams: Promise<{ scenario?: string }> }) {
  const { scenario } = await searchParams;
  return (
    <InvoicesGate>
      <InvoiceListPage scenario={scenario} />
    </InvoicesGate>
  );
}
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
Angular: `inject(ActivatedRoute).snapshot.queryParamMap.get('scenario')`. Next.js App Router:
the page's `searchParams` prop, passed down as above.

For `loading`, render the loading state indefinitely rather than on a timer, so reviewers can
look at it.
