---
tags: [mockship, ui-to-mock]
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

In src/features/customers/CustomerListPage/CustomerListPage.test.tsx, mock api.listCustomers so it returns an empty list, and add a test that the empty state shows.
