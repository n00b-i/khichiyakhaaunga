# Agent Docs — Reading Order

Read in this order at the start of every session.

## Every Session (required)
1. PROJECT_CONTEXT.md — Core rules, non-negotiables
2. state.md — Where we are RIGHT NOW (source of truth)
3. DECISIONS.md — Why past choices were made

## First Session Only (reference later)
4. UI_SYSTEM.md — Design tokens, typography, components
5. DATABASE_SCHEMA.md — Tables, columns, relationships

## When Building Features
6.  Navigation tree
7. ACCEPTANCE_CRITERIA.md + ac/*.md — Per-screen requirements

## When Confused or Debugging
8. architecture.md — Stack, folder structure, principles
9. UX_SECURITY_EDGE_CASES.md — Known issues and past failures

## Status / History
10. roadmap.md — Phase progress
11. tree.md — File structure snapshot
12. prompts.md — Prompting templates

## Update Protocol
- state.md → update at END of every session (agent proposes, user approves)
- DECISIONS.md → append at END of every session (no deletions, ever)
- DATABASE_SCHEMA.md → update when schema changes
- PROJECT_CONTEXT.md → update only when core rules change (rare)
