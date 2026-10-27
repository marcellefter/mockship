---
type: regex
pattern: '^\s*''?[a-z-]*invoice[a-z-]*''?\s*:\s*false\b'
flags: m
target:
  source: file
  path: src/flags.ts
---
