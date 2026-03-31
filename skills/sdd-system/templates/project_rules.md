# Project Rules

## 1. General Principles
- **Spec-Driven**: All code changes must start with a specification update.
- **Single Source of Truth**: The `.sdd/` directory contains the authoritative state of the design.

## 2. Coding Standards
- Keep functions small and focused (SRP).
- Use meaningful variable and function names.
- Document complex logic with inline comments.

## 3. Architecture
- Follow the project's declared architecture style (defined in `context.json.architecture_style`).
- Maintain clear boundaries between layers/modules as defined by the architecture.

## 4. Testing
- Write tests appropriate to the project type (unit, integration, E2E, component, visual regression, etc.).
- Ensure critical paths have test coverage.

## 5. Verify Commands (optional)
<!-- Only include commands that exist for this project. Remove lines that don't apply. -->

## 6. Version Control
- Use feature branches.
- Commit messages must reference the Task ID (e.g., `feat(auth): implement login [TASK-123]`).
