export function formatTotal(total: number, currency: string): string {
  return new Intl.NumberFormat('en', { style: 'currency', currency }).format(total);
}
