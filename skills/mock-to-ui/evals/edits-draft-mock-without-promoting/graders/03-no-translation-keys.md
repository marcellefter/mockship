---
type: regex
pattern: 'invoices'
flags: m
match: not_contains
target:
  source: file
  path: src/i18n/locales/en.json
---
