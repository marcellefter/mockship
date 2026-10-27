---
type: regex
pattern: '"name":"Write","input":\{"file_path":"[^"]*Page[^"]*"[\s\S]*?"name":"(?:Edit|Write|MultiEdit)","input":\{"file_path":"[^"]*src/flags\.ts"'
match: not_contains
target: trace
---
