# Skills Registry

> Bundle skill inventory generated from `SKILL.md` frontmatter for the shipped subset.
> Load a skill by reading its `SKILL.md`.

---

## Skills by Category

### Coding

| Skill | Path | When to Use |
|-------|------|-------------|
| Anchor Review | `coding/anchor-review/` | Single-model adversarial review technique — 3-lens analysis with confidence scoring and self-challenge |
| Api Client Patterns | `coding/api-client-patterns/` | Typed API client patterns for consuming REST APIs and tRPC. Use for typed fetch wrappers, zod response validation, API client factory, auth injection, TanStack Query (useQuery, useMutation, infinite queries, optimistic updates), tRPC end-to-end types, error handling with discriminated unions, OpenAPI client codegen, or pagination envelopes. Complements backend-development (server side) with client-side consumption patterns. |
| Api Design | `coding/api-design/` | REST and GraphQL API design patterns. Use when designing new API endpoints, defining resource schemas, planning versioning strategies, or reviewing API contracts. Covers naming conventions, pagination, filtering, error responses, and OpenAPI documentation. |
| Architecture Design | `coding/architecture-design/` | Design application architecture and system diagrams with layered patterns, Mermaid C4 diagrams, SQL Server data platform, and on-premise deployment considerations. |
| Backend Development | `coding/backend-development/` | Backend API design, database architecture, microservices patterns, and test-driven development. Use for designing APIs, database schemas, or backend system architecture. |
| Backend To Frontend Handoff Docs | `coding/backend-to-frontend-handoff/` | Create API handoff documentation for frontend developers. Use when backend work is complete and needs to be documented for frontend integration, or user says 'create handoff', 'document API', 'frontend handoff', or 'API documentation'. |
| Caching Patterns | `coding/caching-patterns/` | Caching strategies for Streamlit and FastAPI applications |
| Code Explainer | `coding/code-explainer/` | Explain code with visual diagrams, analogies, and step-by-step walkthroughs. Use when explaining how code works, teaching about a codebase, or answering "how does this work? |
| Code Review | `coding/code-review/` | Automated code review for pull requests using specialized review patterns. Analyzes code for quality, security, performance, and best practices. Use when reviewing code changes, PRs, or doing code audits. |
| Codebase Audit | `coding/codebase-audit/` | Systematic codebase audit methodology for unfamiliar codebases before architecture or implementation work. Use for new codebase, unfamiliar codebase, pre-implementation audit, codebase review, technical due diligence, or onboarding to an existing project. Produces AUDIT-FINDINGS.md and QUESTIONS.md. Routes to Architect, Planner, or Code Reviewer agents. |
| Error Handling | `coding/error-handling/` | Error handling patterns for Python and TypeScript applications. Use when designing error hierarchies, implementing retry logic, building error boundaries, or establishing logging strategies. Covers custom exceptions, result types, circuit breakers, and user-facing error messages. |
| Fastapi Dev | `coding/fastapi-dev/` | Build FastAPI backends with standard patterns, error handling, and testing |
| Javascript Typescript | `coding/javascript-typescript/` | JavaScript and TypeScript development with ES6+, Node.js, React, and modern web frameworks. Use for frontend, backend, or full-stack JavaScript/TypeScript projects. |
| Llm Application Dev | `coding/llm-application-dev/` | Building applications with Large Language Models - prompt engineering, RAG patterns, and LLM integration. Use for AI-powered features, chatbots, or LLM-based automation. |
| Mcp Builder | `coding/mcp-builder/` | Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK). |
| Observability | `coding/observability/` | Structured logging, OpenTelemetry distributed tracing, metrics (RED method), health checks, and error tracking with Sentry. Use for structured logs, correlation IDs, PII redaction, OpenTelemetry setup, distributed tracing, metrics counters/histograms/gauges, SLO-based alerting, liveness/readiness probes, or Sentry integration. Dual Python/TypeScript examples throughout. |
| Python Development | `coding/python/` | Modern Python development with Python 3.12+, Django, FastAPI, async patterns, and production best practices. Use for Python projects, APIs, data processing, or automation scripts. |
| Refactoring | `coding/refactoring/` | Safely refactor code while maintaining behavior. Use when improving code structure, reducing duplication, extracting functions, or modernizing legacy code. |
| Security Review | `coding/security-review/` | Security review workflow — OWASP, code scanning, cloud infrastructure |
| Sql | `coding/sql/` | Write high-quality, optimized SQL with best practices for performance, NULL handling, security, and readability. Database-agnostic patterns with dialect-specific notes. |
| Understand Anything | `coding/understand-anything/` | > |

### Data

| Skill | Path | When to Use |
|-------|------|-------------|
| Data Analysis | `data/data-analysis/` | Analyze datasets and generate insights with a systematic 5-phase workflow. Use when user provides data for analysis, asks about patterns, or needs visualizations. |
| Data Loader | `data/data-loader/` | Load data from files (Excel, JSON, CSV) into databases. Use when user needs to import data files into any database system. Database-agnostic - supports SQL Server, PostgreSQL, MySQL, SQLite, and others. |
| Data Validation | `data/data-validation/` | Data quality and validation patterns for ETL pipelines, API inputs, and data processing. Use when defining validation rules, building data quality checks, implementing schema validation, or designing data contracts. Covers Pydantic, Great Expectations patterns, and SQL-level constraints. |
| Database Design | `data/database-design/` | Database schema design, optimization, and migration patterns for PostgreSQL, MySQL, and NoSQL databases. Use for designing schemas, writing migrations, or optimizing queries. |
| Db Testing | `data/db-testing/` | Test, debug, and validate database connectivity and queries. Use when diagnosing connection errors, testing configurations, or validating queries before deployment. |
| Schema Migration | `data/schema-migration/` | Migrate an application's data access layer from one database schema to another. Use when tables are renamed, consolidated, split, or columns change — and the app's queries, mappings, and abstraction layer must be updated without data loss. Read-only against the database. |

### Devops

| Skill | Path | When to Use |
|-------|------|-------------|
| Changelog Generator | `devops/changelog-generator/` | Automatically creates user-facing changelogs from git commits by analyzing commit history, categorizing changes, and transforming technical commits into clear, customer-friendly release notes. Turns hours of manual changelog writing into minutes of automated generation. |
| Ci Cd Pipeline | `devops/ci-cd-pipeline/` | CI/CD pipeline design and implementation for GitHub Actions, Azure DevOps, and general pipeline architecture. Use when creating build pipelines, deployment workflows, quality gates, environment promotion strategies, or automating release processes. |
| Deploy Local | `devops/deploy-local/` | End-to-end local deployment loop for VMIE Gitea projects. Use when the user wants to commit on dev, push to remote, monitor the golden CI/build/deploy workflow, validate prod on iegbcoppoc02, and fix lint/test/pipeline failures until deployment is healthy. |
| Gh Cli | `devops/gh-cli/` | GitHub CLI operations — issues, PRs, releases, and repo management |
| Git Commit | `devops/git-commit/` | Create well-structured conventional commit messages following Conventional Commits standard. Use when committing changes, preparing PRs, or generating changelogs. |
| Monorepo | `devops/monorepo/` | Monorepo management with Turborepo and pnpm workspaces. Use for Turborepo setup, turbo.json task dependencies, remote caching, pnpm workspace protocol, shared packages (ui-library, config, types), affected-only CI/CD builds, or monorepo structure (apps/ vs packages/). Covers pitfalls like circular deps, version drift, and hoisting issues. |
| Update Readme | `devops/update-readme/` | Detect feature commits and update README sections (Features, API, Usage) with accurate repo-aware changes, then stage only README for a docs commit. Use when users add features/routes/components and want README maintained automatically. |
| Using Git Worktrees | `devops/using-git-worktrees/` | Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification |

### Docs

| Skill | Path | When to Use |
|-------|------|-------------|
| Architecture Document | `docs/architecture-document/` |  |
| Code Documentation | `docs/code-documentation/` | Writing effective code documentation - API docs, README files, inline comments, and technical guides. Use for documenting codebases, APIs, or writing developer guides. |
| Doc Coauthoring | `docs/doc-coauthoring/` | Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks. |
| Documentation Analyzer | `docs/documentation-analyzer/` | Analyze codebases, explain code functionality, and generate comprehensive documentation. Use when documenting a project, creating README files, or understanding complex code. |
| Naming Analyzer | `docs/naming-analyzer/` | Suggest better variable, function, and class names based on context and conventions. |
| Prd To Code | `docs/prd-to-code/` | Transform PRD documents into working application code using a systematic 6-phase methodology. Use when starting projects from requirements or converting specs to implementation. |
| Technical Writing | `docs/technical-writing/` | Technical documentation best practices for READMEs, API docs, architecture docs, runbooks, and developer guides. Use when writing or reviewing documentation, creating onboarding guides, or establishing documentation standards. |
| Writing Plans | `docs/writing-plans/` | Use when you have a spec or requirements for a multi-step task, before touching code |

### Frontend

| Skill | Path | When to Use |
|-------|------|-------------|
| Css Architecture | `frontend/css-architecture/` | CSS architecture, design token strategy, Tailwind conventions, CSS Modules, container queries, dark mode, responsive patterns, and animation architecture. Use for design token naming, CSS custom properties, Tailwind config, container queries, dark mode implementation, fluid typography, or CSS animation decisions. Complements frontend-design (what to achieve) with how to implement it. |
| Design System Tokens | `frontend/design-system-tokens/` | Token architecture and component specifications. Three-layer tokens (primitive → semantic → component), CSS variables, spacing/typography scales, and component state definitions. Use for design token creation and systematic design. |
| Enterprise Dashboard Aesthetic System | `frontend/enterprise-dashboard-aesthetic-system/` | Use when: upgrading React/Vite enterprise dashboards, harmonizing dashboard pages, improving executive analytics UI aesthetics, creating cohesive dashboard design systems, adding tasteful motion, or turning data-heavy pages into a polished narrative cockpit. Applies to RevSight-style FastAPI + React + Tailwind + shadcn dashboards. |
| Frontend Design | `frontend/frontend-design/` | Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications. Generates creative, polished code that avoids generic AI aesthetics while strictly adhering to the user's technical standards. |
| Mockup | `frontend/mockup/` | Create framework-aware UI mockups with feasibility checks. Prevents wasted effort by validating that proposed designs work within the target framework's constraints. |
| Nextjs App Router | `frontend/nextjs-app-router/` | Next.js 13+ App Router conventions, Server vs Client Components, Server Actions, Middleware, data fetching, Metadata API, and route handlers. Use for Next.js App Router directory structure, Server Actions, SSR/RSC patterns, generateMetadata, layout/page/error/loading.tsx conventions, route groups, parallel routes, or hydration issues. Companion to react-dev and react-best-practices. |
| React Best Practices | `frontend/react-best-practices/` | Modern React development guidelines covering hooks, component patterns, state management, performance optimization, and TypeScript integration. |
| React Dev | `frontend/react-dev/` | This skill should be used when building React components with TypeScript, typing hooks, handling events, or when React TypeScript, React 19, Server Components are mentioned. Covers type-safe patterns for React 18-19 including generic components, proper event typing, and routing integration (TanStack Router, React Router). |
| React Useeffect | `frontend/react-useeffect/` | React useEffect best practices from official docs. Use when writing/reviewing useEffect, useState for derived values, data fetching, or state synchronization. Teaches when NOT to use Effect and better alternatives. |
| Responsive Mobile Native | `frontend/responsive-mobile-native/` | > |
| Shadcn Radix | `frontend/shadcn-radix/` | shadcn/ui component library, Radix UI primitives, theming with CSS variables, react-hook-form + zod forms, TanStack Table data tables, and cva variant composition. Use for shadcn setup, shadcn add, components.json, shadcn theming, Radix accessible components, shadcn form patterns, data tables, command palette, date picker, combobox, or drawer/sheet. References css-architecture for tokens and react-best-practices for structure. |
| Streamlit Dev | `frontend/streamlit-dev/` | Build production-ready Streamlit dashboards with best-practice patterns, caching, components, and theming. Use when implementing any Streamlit page, component, chart, or UI feature. |
| Theme Factory | `frontend/theme-factory/` | Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, etc. There are 10 pre-set themes with colors/fonts that you can apply to any artifact that has been creating, or can generate a new theme on-the-fly. |
| Ui Review | `frontend/ui-review/` | Review UI implementations against design requirements, accessibility standards (WCAG 2.2 AA), and brand guidelines. Use when reviewing designs or validating UI before release. |
| Ui Styling Patterns | `frontend/ui-styling-patterns/` | Create accessible user interfaces with shadcn/ui components (Radix UI + Tailwind), Tailwind CSS utility-first styling, and canvas-based visual designs. Use for responsive layouts, accessible components, theme customization, dark mode, and consistent styling patterns. |
| Ui Ux Intelligence | `frontend/ui-ux-intelligence/` | UI/UX design intelligence with CSV knowledge bases: 50+ styles, 161 color palettes, 57 font pairings, 161 product types, 99 UX guidelines, and 25 chart types. Use when making design decisions that need data-backed palettes, font pairing lookups, or style-specific implementation guidance. |
| Warm Editorial Ui | `frontend/warm-editorial-ui/` | Apply the "Warm Editorial Refinement" design system — a sophisticated, executive-grade aesthetic with warm cream surfaces (light mode) and warm charcoal surfaces (dark mode), Bahnschrift + Plus Jakarta Sans typography, generous rounded corners, multi-layer shadows, and a warm neutral palette. Supports both light and dark themes via CSS custom properties and the `.dark` class. Use this skill whenever the user wants to build an app, dashboard, component, or web UI using the abc-project visual style. Trigger on phrases like "use our design system", "apply our template", "make it look like abc-project", "use the warm editorial style", "use our brand template", "add dark mode", or any request to build a new tool/app/dashboard for XYZ Brand or similar contexts. This is the canonical design template for all new frontend builds. |
| Webapp Development | `frontend/webapp-development/` | End-to-end web application development workflow with brand theming and standard patterns |
| Word Cloud | `frontend/word-cloud/` | Generate beautiful word clouds — static or animated — from any input source. Handles text extraction from PDF, DOCX, XLSX, PPTX, HTML, CSV, TXT and produces production-ready components. Includes light/dark theming, sentiment/POS color coding, shape masking, and multiple animation modes. |

### Media

| Skill | Path | When to Use |
|-------|------|-------------|
| Draw Io | `media/draw-io/` | draw.io diagram creation, editing, and review. Use for .drawio XML editing, PNG conversion, layout adjustment, and AWS icon usage. |
| Excalidraw | `media/excalidraw/` | Brand-themed Excalidraw diagrams for project documentation |
| Mermaid Diagrams | `media/mermaid-diagrams/` | Create software diagrams using Mermaid text-based syntax. Use for class diagrams (domain modeling, OOP design), sequence diagrams (API flows, interactions), flowcharts (processes, algorithms, user journeys), ERD (database schemas), C4 architecture diagrams, state diagrams, git graphs, gantt charts, and data visualization. |
| Plantuml | `media/plantuml/` | Brand-themed PlantUML diagrams for project documentation |
| Svg Create | `media/svg-create/` | Brand-themed SVG diagrams with consistent color palette and accessible design |

### Productivity

| Skill | Path | When to Use |
|-------|------|-------------|
| Github Issues | `productivity/github-issues/` | Create well-structured GitHub issues with proper labels, descriptions, and acceptance criteria. Use when creating bug reports, feature requests, or tracking tasks. |
| Jira Issues | `productivity/jira-issues/` | Create, update, and manage Jira issues from natural language. Use when the user wants to log bugs, create tickets, update issue status, or manage their Jira backlog. |

### Testing

| Skill | Path | When to Use |
|-------|------|-------------|
| Component Testing | `testing/component-testing/` | React component testing with Vitest, Testing Library, MSW, and renderHook. Use for Vitest setup, jsdom/happy-dom config, Testing Library queries, userEvent, component unit tests, testing React hooks, MSW API mocking, snapshot testing, or testing loading/error states. Complements playwright (E2E) and tdd-workflow (methodology). |
| Performance Testing | `testing/performance-testing/` | Performance testing, load testing, and benchmarking for APIs, databases, and web applications. Use when planning load tests, setting performance budgets, profiling bottlenecks, or validating scalability. Covers Locust, k6, pytest-benchmark, browser performance, and database query profiling. |
| Playwright | `testing/playwright/` | Complete browser automation with Playwright. Auto-detects dev servers, writes clean test scripts to /tmp. Test pages, fill forms, take screenshots, check responsive design, validate UX, test login flows, check links, automate any browser task. Use when user wants to test websites, automate browser interactions, validate web functionality, or perform any browser-based testing. |
| Tdd Workflow | `testing/tdd-workflow/` | Test-Driven Development workflow — red-green-refactor cycle |
| Test Strategy | `testing/test-strategy/` | Test planning and strategy for projects of any size. Use when defining what to test, choosing test types, setting coverage goals, building test pyramids, or planning quality gates. Produces TEST-STRATEGY.md with prioritized test plan. Routes to Tester agent for execution. |
| Ui Testing | `testing/ui-testing/` | Create automated UI tests using Playwright for Streamlit and web applications. Use when writing end-to-end tests, automating UI testing, or testing new features. |
| Webapp Testing | `testing/webapp-testing/` | Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs. |

### Vmie

| Skill | Path | When to Use |
|-------|------|-------------|
| Golden Workflow | `vmie/golden-workflow/` | Standardize VMIE Gitea workflows onto the Golden VMIE Workflow for the local shared-runner infra model. Use whenever an existing app has brittle tag-first deploy logic, split CI and deploy files, manual deploy drift, or runner-safe workflow issues, and also whenever a new repo must inherit the correct default CI/CD flow. Covers runner contract, canonical ci.yml, SHA-driven prod deploy on iegbcoppoc02, post-deploy CalVer tagging, bootstrap alignment, repo migration, and mandatory first-run execution plus validation. |
| Windows Deployment | `vmie/windows-deployment/` | Windows deployment guidance for app services running under NSSM with reverse proxy support. |

### Workflow

| Skill | Path | When to Use |
|-------|------|-------------|
| Agent Md Refactor | `workflow/agent-md-refactor/` | Refactor bloated agent instruction files (AGENTS.md, .cursorrules, .github/ files, etc.) to follow progressive disclosure principles. Splits monolithic files into organized, linked documentation. |
| Ask Questions If Underspecified | `workflow/asking-questions/` | Clarify requirements before implementing. Do not use automatically, only when invoked explicitly. |
| Best Practices | `workflow/best-practices/` | >- |
| Brainstorming | `workflow/brainstorming/` | You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation. |
| Context Curator | `workflow/context-curator/` | Compress and prioritize codebase context before handing work to reasoning agents, minimizing token waste while preserving the required decision inputs. |
| Data Contract Pipeline | `workflow/data-contract-pipeline/` | **WORKFLOW SKILL** - Build, audit, and validate data-to-UI contracts for apps. Use whenever the user mentions data mapping, UI lineage, DB-to-UI, DisplayDTOs, source-to-screen mapping, data contracts, schema drift, typed API responses, frontend type alignment, mockup grounding, requirements-to-UI mapping, or asks whether a UI is backed by real DB/file data. Works for DBs, JSON, Markdown, CSV, XLSX, YAML, APIs, and UI mockups. |
| Golden Nuggets | `workflow/golden-nuggets/` | Extract durable tribal knowledge ('gold nuggets') from a codebase or a set of changed files and route each to its correct destination - instruction file, runbook, hub, or (in CI capture mode) a review inbox. This SKILL.md is the single source of truth for nugget categories, routing rules, write rules, inbox format, and verification gates. It is read by the knowledge-transfer agent (pipeline mode), by the /golden-nuggets prompt (independent mode), and referenced by the CI extraction script (capture mode). Use when capturing what was learned after a feature, fix, sprint, incident, or release. |
| Golden Plan | `workflow/golden-plan/` | USE THIS SKILL whenever a user asks for a comprehensive implementation plan, a full-stack build plan, a UI+backend plan, or says 'create a plan for building X' where X spans multiple phases or systems. Also activate when the user says 'plan this project', 'I need a detailed plan', 'build plan', 'implementation plan', or attaches a mockup/wireframe and asks how to build it. Produces a zero-ambiguity, evidence-gated plan with self-contained per-phase prompts, exhaustive data binding tables, per-phase validation checklists, and a global quality gate. Evidence-gated: before writing phases, verify required artefacts (mockup, data sample, API contract, scaffold inventory); if any BLOCKER is missing, ask for it and wait before proceeding. Dual-mode: generic by default, junai-pipeline only when explicitly requested. Agent-agnostic - any agent with read/search/edit tools can use this skill. |
| Intent Writer | `workflow/intent-writer/` | Structure freetext ideas, backlog items, or vague requirements into a formal Intent Document that preserves user intent across the entire agent pipeline chain. |
| Onboard Project | `workflow/onboard-project/` | Bootstrap a new project's AI configuration by generating copilot-instructions.md and populating project-config.md. Idempotent — safe to re-run on existing projects. |
| Preflight | `workflow/preflight/` | Plan-vs-codebase validation — verifies API contracts, type names, field accuracy, dependencies, and paths before implementation begins |
| Receiving Code Review | `workflow/receiving-code-review/` | Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification, not performative agreement or blind implementation |
| Relay | `workflow/relay/` | Create or update a root relay.md session-continuation document for any repository. Use this skill whenever the user asks to preserve project context, resume later, hand work to a future session, create a session relay, summarize current implementation state, or generate a reusable continuation prompt. The workflow is generic and must discover project structure at runtime. |
| Requesting Code Review | `workflow/requesting-code-review/` | Use when completing tasks, implementing major features, or before merging to verify work meets requirements |
| Setup Project Ai | `workflow/setup-project-ai/` | Install or refresh the agent-agnostic Claude Code development harness in a project — CLAUDE.md hierarchy (root + per-folder), AGENTS.md mirror, lean subagents, slash commands, settings.json, and the frontend/python test env. USE THIS SKILL when setting up AI resources on a new or existing project, bootstrapping CLAUDE.md, adding subagents/commands, or when the user says 'set up the harness', 'setup-project-ai', 'generate CLAUDE.md', 'onboard this project to Claude Code', or runs /setup-project-ai. Combines a deterministic generator (scripts/setup_project_ai.py) for the must-not-vary mechanics with an AI enrichment step that curates project-specific CLAUDE.md content. |
| Skill Creator | `workflow/skill-creator/` | Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. |
| State Tracking | `workflow/state-tracking/` | USE THIS SKILL when an agent needs to maintain a living record of task progress across multiple sessions or hand-offs. Covers append-only audit logs, CURRENT_STATE head-of-line pattern, relay hand-off protocol, and recovery from mid-session interruptions. Works in both generic and junai-pipeline modes. |
| Verification Loop | `workflow/verification-loop/` | Systematic code change verification — lint, test, type-check, review |
