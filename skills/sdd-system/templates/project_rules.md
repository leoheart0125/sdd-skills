# Project Rules

## 1. General Principles
- **Spec-Driven**: All code changes must start with a specification update.
- **Single Source of Truth**: The `.sdd/` directory contains the authoritative state of the design.

## 2. Tech Stack
<!-- List all languages, frameworks, runtimes, databases, and tooling.
     For multi-stack projects, group by service/component (e.g., frontend, backend, infra). -->

| Component | Technology |
|-----------|------------|
| Language  | {{ language }} |
| Framework | {{ framework }} |
| Package Manager | {{ package_manager }} |
| Testing   | {{ testing_framework }} |

## 3. Coding Standards
- Keep functions small and focused (SRP).
- Use meaningful variable and function names.
- Document complex logic with inline comments.

## 4. Architecture
- Follow the architecture style and directory structure conventions defined in this file.
- Maintain clear boundaries between layers/modules as defined by the architecture.

## 5. Testing
- Write tests appropriate to the project type (unit, integration, E2E, component, visual regression, etc.).
- Ensure critical paths have test coverage.

## 6. Verify Commands (optional)
<!-- Only include commands that exist for this project. Remove lines that don't apply. -->

## 7. Version Control
- Use feature branches.
- Commit messages must reference the Task ID (e.g., `feat(auth): implement login [TASK-123]`).
