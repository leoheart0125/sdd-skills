# Project Rules

## 1. General Principles
- **Spec-Driven**: All code changes must start with a specification update.
- **Single Source of Truth**: The `.sdd/` directory contains the authoritative state of the design.

## 2. Coding Standards
- Keep functions small and focused (SRP).
- Use meaningful variable and function names.
- Document complex logic with inline comments.

## 3. Architecture
- Follow the defined architecture patterns (e.g., Clean Architecture, Modular Monolith).
- Dependencies should flow inwards (Domain -> Use Cases -> Adapters).

## 4. Testing
- Write unit tests for all business logic.
- Ensure integration tests cover critical paths.

## 5. Version Control
- Use feature branches.
- Commit messages must reference the Task ID (e.g., `feat(auth): implement login [TASK-123]`).
