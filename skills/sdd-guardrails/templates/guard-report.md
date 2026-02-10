# Guardrails Validation Report

**Date:** {{ date }}
**Task ID:** {{ task_id }}
**Feature:** {{ feature_id }}

## Summary
- **Total Checks:** {{ total_checks }}
- **Passed:** {{ passed }}
- **Failed:** {{ failed }}
- **Status:** {{ status }}  <!-- PASSED / FAILED -->

## Detailed Findings

### 1. Requirements Validation
| ID | Requirement | Status | Issue |
|----|-------------|--------|-------|
{{#requirements}}
| {{id}} | {{description}} | {{status}} | {{issue}} |
{{/requirements}}

### 2. Architecture Validation
| Component | Compliance | Issue |
|-----------|------------|-------|
{{#architecture}}
| {{component}} | {{status}} | {{issue}} |
{{/architecture}}

### 3. Code Standards & Static Analysis
| File | Issue | Severity |
|------|-------|----------|
{{#code_issues}}
| {{file}} | {{message}} | {{severity}} |
{{/code_issues}}

### 4. Rule Compliance (project_rules.md)
| Rule | Source | Status | Detail |
|------|--------|--------|--------|
{{#rule_checks}}
| {{rule}} | {{source}} | {{status}} | {{detail}} |
{{/rule_checks}}

### 5. Plan Checks (target_path validation)
| Task ID | Target Path | Convention | Status | Issue |
|---------|-------------|------------|--------|-------|
{{#plan_checks}}
| {{task_id}} | {{target_path}} | {{convention}} | {{status}} | {{issue}} |
{{/plan_checks}}

## Lessons Triggered
{{#lessons_triggered}}
- **{{trigger}}**: {{advice}}
{{/lessons_triggered}}

## Recommendations
- [ ] Fix critical issues listed above.
- [ ] Update requirements if implementation intentionally deviated.
- [ ] Review triggered lessons and confirm via `/sdd-learn`.
