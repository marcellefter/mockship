---
type: regex
pattern: '^\s*''[a-z-]+'': false,$'
flags: m
match: 'count:1'
target:
  source: file
  path: src/flags.ts
---
