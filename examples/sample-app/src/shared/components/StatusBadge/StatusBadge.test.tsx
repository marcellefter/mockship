import { render, screen } from '@testing-library/react';
import { StatusBadge } from '.';

// Every tone maps to its own token pair; a tone without a class would render unstyled.
it.each(['neutral', 'info', 'success', 'warning', 'danger'] as const)('renders the %s tone with its class', (tone) => {
  render(<StatusBadge tone={tone} label="Label" />);
  expect(screen.getByText('Label')).toHaveClass(tone);
});
