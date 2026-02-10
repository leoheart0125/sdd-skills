# Guardrails Validation Report

**Date:** {{ date }}
**Task ID:** {{ task_id }}

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

## Recommendations
- [ ] Fix critical issues listed above.
- [ ] Update requirements if implementation intentionally deviated.
