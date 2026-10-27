---
type: regex
pattern: '\bInvoice\b[^\n]*from ''[^'']*api/'
flags: m
target:
  source: file
  path: src/features/invoices/mockData.ts
---
