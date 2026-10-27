---
type: llm
focus: trace
weight: 1
---

Fixtures in a mockData module are typed with the existing Invoice type from src/api and seed local state; no file in the feature folder imports src/api/client.ts or @tanstack/react-query, or calls fetch.
