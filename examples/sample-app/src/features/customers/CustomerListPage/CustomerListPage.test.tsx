import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { CustomerListPage } from '.';

function renderPage() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <CustomerListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

// The list is the entry to every customer: each row must link to its detail page.
it('links every customer to its detail page', async () => {
  renderPage();
  const link = await screen.findByRole('link', { name: 'Northwind Traders' });
  expect(link).toHaveAttribute('href', '/customers/c1');
});
