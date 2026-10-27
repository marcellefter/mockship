---
type: llm
focus:
  source: file
  path: src/features/invoices/InvoiceDetailPage/index.tsx
weight: 1
---

The detail page reads and writes through the API client via data-fetching hooks (not mock data), and shows Change status and Delete only when useCan('invoices:manage') is true.
